module Data.Web.PreviousResults exposing (..)

import Http exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Data.Web.Normalise exposing (..)
import Data.Web.Answers exposing (..)
import Model exposing (..)
import Dict exposing (..)


getPreviousResults : Cmd Msg
getPreviousResults =
    Http.get "/api/previous-results/15" previousResultsDecoder
        |> Http.send ReceivePreviousResults


previousResultsDecoder : Decoder PreviousResults
previousResultsDecoder =
    decode PreviousResults
        |> required "user" rawUserDecoder
        |> required "answers" answersDecoder


answersDecoder : Decoder (List ( QuoteId, Answer ))
answersDecoder =
    field "answers" (dict bool)
        |> andThen (\x -> (succeed (transformRawAnswers x)))


transformRawAnswers : Dict String Bool -> List ( QuoteId, Answer )
transformRawAnswers answers =
    answers
        |> Dict.toList
        |> List.map (\( qId, answerBool ) -> ( String.toInt qId, boolToAnswer answerBool ))
        |> List.map (\( x, y ) -> ( Result.withDefault 0 x, y ))


rawUserDecoder : Decoder RawUser
rawUserDecoder =
    decode RawUser
        |> required "id" int
        |> required "name" string
        |> required "age_range" ageRangeDecoder
        |> required "email" string
        |> required "postcode" string


ageRangeDecoder : Decoder AgeRange
ageRangeDecoder =
    string |> andThen (\x -> (succeed (stringToAgeRange x)))
