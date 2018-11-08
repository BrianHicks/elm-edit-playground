module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Model =
    { lastChange : Maybe Input }


type Msg
    = Changed Input


type alias Input =
    { data : Maybe String
    , inputType : String
    , isComposing : Bool
    }


decodeInput : Decoder Input
decodeInput =
    Decode.map3 Input
        (Decode.field "data" (Decode.nullable Decode.string))
        (Decode.field "inputType" Decode.string)
        (Decode.field "isComposing" Decode.bool)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Changed val ->
            ( { model | lastChange = Just val }, Cmd.none )


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
debug { lastChange } =
    Html.pre [] [ Html.text <| Debug.toString lastChange ]


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> ( { lastChange = Nothing }, Cmd.none )
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
