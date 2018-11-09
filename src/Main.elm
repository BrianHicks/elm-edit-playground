module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Model =
    { events : List Event }


type Msg
    = Changed Event


type Event
    = InsertText String
    | DeleteForward
    | DeleteBackward


decodeInput : Decoder Event
decodeInput =
    Decode.andThen
        (\inputType ->
            case inputType of
                "deleteContentBackward" ->
                    Decode.succeed DeleteBackward

                "deleteContentForward" ->
                    Decode.succeed DeleteForward

                "insertText" ->
                    Decode.map InsertText (Decode.field "data" Decode.string)

                _ ->
                    Decode.fail ("don't know what to do with a '" ++ inputType ++ "' from the input event!")
        )
        (Decode.field "inputType" Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Changed val ->
            ( { model | events = val :: model.events }, Cmd.none )


view : Model -> Html Msg
view _ =
    div
        [ attribute "contenteditable" "true"

        -- TODO: composeend to catch stuff like ñ and é
        , on "input" (Decode.map Changed decodeInput)
        ]
        [ strong [] [ text "Hey " ]
        , em [] [ text "what's up?" ]
        ]


debug : Model -> Html Msg
debug { events } =
    Html.ul [] (List.map (Html.li [] << List.singleton << Html.text << Debug.toString) events)


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> ( { events = [] }, Cmd.none )
        , update = update
        , view =
            \model ->
                { title = "Elm Edit"
                , body =
                    [ view model
                    , debug model
                    ]
                }
        , subscriptions = \_ -> Sub.none
        }
