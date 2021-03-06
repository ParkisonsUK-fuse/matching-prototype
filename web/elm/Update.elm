module Update exposing (..)

import Data.Answers exposing (handleAnswer)
import Data.Ports exposing (trackOutboundLink)
import Data.QuoteServiceWeightings exposing (setQuoteServiceWeightings)
import Data.Quotes exposing (..)
import Data.Services exposing (..)
import Data.Shuffle exposing (..)
import Data.UserInfo exposing (emailToString, handleName, storeSubmittedEmail, validateEmail, validatePostcode)
import Dict
import Helpers.Delay exposing (..)
import Helpers.Errors exposing (..)
import Model exposing (..)
import Model.Email as Email
import Model.Postcode as Postcode
import Navigation
import Web.Answers exposing (handlePostAnswers, handlePostAnswersLoading)
import Web.Results.EntryPoint exposing (..)
import Web.Results.Url exposing (..)
import Web.User exposing (..)
import Web.UserEmail exposing (..)


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        model =
            setEntryPoint location initialModel
    in
        model ! handleGetUserData model


initialModel : Model
initialModel =
    { view = Home
    , name = Nothing
    , postcode = Postcode.NotEntered
    , ageRange = Nothing
    , email = Email.NotEntered
    , emailConsent = False
    , userId = Nothing
    , quotes = Dict.empty
    , services = Dict.empty
    , top3Services = []
    , weightings = Dict.empty
    , fetchErrorMessage = ""
    , submitErrorMessage = ""
    , currentQuote = Nothing
    , remainingQuotes = Nothing
    , userWeightings = Dict.empty
    , userAnswers = []
    , entryPoint = Start
    , answerUuid = Nothing
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetView view ->
            { model | view = view } ! []

        SetName name ->
            handleName model name ! []

        SetPostcode postcode ->
            { model | postcode = validatePostcode postcode } ! []

        SetAgeRange ageRange ->
            { model | ageRange = Just ageRange } ! []

        SetEmail email ->
            { model | email = validateEmail email } ! []

        SetEmailConsent bool ->
            let
                newModel =
                    { model | emailConsent = bool }
            in
                newModel ! [ sendEmailConsent newModel ]

        ReceiveQuoteServiceWeightings (Err _) ->
            (model |> quotesServiceWeightingsError) ! []

        ReceiveQuoteServiceWeightings (Ok data) ->
            (model |> setQuoteServiceWeightings data |> removeFetchError) ! [ shuffleQuoteIds <| getQuoteIds data.quotes ]

        ShuffleQuoteIds qIds randomList ->
            (model |> handleShuffleQuotes qIds randomList) ! []

        SubmitAnswer answer ->
            let
                newModel =
                    model
                        |> handleAnswer answer
                        |> handlePostAnswersLoading
            in
                newModel ! [ handlePostAnswers newModel ]

        HandleGoToInstructions ->
            handleGoToInstructions model ! [ postUserDetails model ]

        ReceiveUser (Err _) ->
            (model |> receiveUserError) ! []

        ReceiveUser (Ok rawUser) ->
            (model |> handleRetrievedUserData rawUser |> removeFetchError) ! []

        PutUserEmail (Err _) ->
            (model |> putUserEmailError) ! []

        PutUserEmail (Ok _) ->
            (model |> storeSubmittedEmail |> removeSubmitError) ! []

        PutUserEmailConsent (Err _) ->
            (model |> putUserEmailConsentError) ! []

        PutUserEmailConsent (Ok _) ->
            (model |> removeSubmitError) ! []

        SubmitEmail ->
            model ! [ sendUserEmail model ]

        PostUserAnswers (Err _) ->
            (model |> postUserAnswersError) ! []

        PostUserAnswers (Ok answerUuid) ->
            let
                newModel =
                    { model | answerUuid = Just answerUuid }
                        |> handleTop3Services
                        |> removeSubmitError
            in
                newModel ! [ setResultsUrl newModel, waitThenShowServices ]

        UrlChange _ ->
            model ! []

        ReceiveResults (Err err) ->
            (model |> receiveResultsError) ! []

        ReceiveResults (Ok res) ->
            (model |> loadResults res |> removeFetchError) ! []

        TrackOutboundLink url ->
            model ! [ trackOutboundLink url ]
