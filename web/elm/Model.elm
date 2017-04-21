module Model exposing (..)

import Dict exposing (..)
import Http
import Navigation


type alias Model =
    { view : View
    , name : Maybe String
    , postcode : Postcode
    , ageRange : Maybe AgeRange
    , email : Email
    , userId : Maybe Int
    , quotes : Quotes
    , services : Services
    , top3things : List ServiceData
    , weightings : Weightings
    , earlyOnsetWeightings : Weightings
    , fetchErrorMessage : String
    , currentQuote : Maybe QuoteId
    , remainingQuotes : Maybe (List QuoteId)
    , userWeightings : WeightingsDict
    , userAnswers : List ( QuoteId, Answer )
    , entryPoint : EntryPoint
    , uuid : Maybe String
    }


type View
    = Home
    | Name
    | Postcode
    | Age
    | Quotes
    | Services


type AgeRange
    = UnderForty
    | Forties
    | Fifties
    | Sixties
    | Seventies
    | OverEighty


type Postcode
    = NotEnteredPostcode
    | ValidPostcode String
    | InvalidPostcode String


type Answer
    = Yes
    | No


type Email
    = NotEnteredEmail
    | ValidEmail String
    | InvalidEmail String
    | RetrievedEmail String
    | SubmittedEmail String


type alias Quotes =
    Dict QuoteId String


type alias Services =
    Dict ServiceId ServiceData


type alias ServiceData =
    { title : String
    , body : String
    , cta : String
    , url : String
    , earlyOnset : Bool
    }


type alias Weightings =
    Dict QuoteId WeightingsDict


type alias WeightingsDict =
    Dict ServiceId Float


type alias RawWeighting =
    { quote_id : Int
    , service_id : Int
    , weight : Float
    }


type alias RawUser =
    { id : Int
    , name : String
    , ageRange : AgeRange
    , email : String
    , postcode : String
    }


type alias QuoteId =
    Int


type alias ServiceId =
    Int


type alias Results =
    { user : RawUser
    , answers : List ( QuoteId, Answer )
    , quotes : Quotes
    , services : Services
    , weightings : Weightings
    }


type alias QuoteServiceWeightings =
    { quotes : Quotes
    , services : Services
    , weightings : Weightings
    }


type EntryPoint
    = Start
    | Finish String


type Msg
    = SetView View
    | SetName String
    | SetPostcode String
    | SetAgeRange AgeRange
    | SetEmail String
    | ReceiveQuoteServiceWeightings (Result Http.Error QuoteServiceWeightings)
    | ShuffleQuoteIds (List QuoteId) (List Int)
    | SubmitAnswer Answer
    | HandleGoToQuotes
    | ReceiveUserId (Result Http.Error Int)
    | PutUserEmail (Result Http.Error ())
    | SubmitEmail
    | PostUserAnswers (Result Http.Error String)
    | UrlChange Navigation.Location
    | ReceiveResults (Result Http.Error Results)
