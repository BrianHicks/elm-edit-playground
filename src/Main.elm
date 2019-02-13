module Main exposing (main)

import Browser
import Doc exposing (Doc)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Model =
    { events : List Msg
    , doc : Doc
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { events = []
      , doc = Doc.sampleDoc
      }
    , Cmd.none
    )


type RawHtml
    = RawHtml String


type Msg
    = Changed Event
    | Pasted RawHtml


type Event
    = InsertText String
    | DeleteForward
    | DeleteBackward
    | ChangeSelection Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( { model | events = msg :: model.events }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    main_
        []
        [ p [] [ text (Debug.toString model.doc) ]
        , node "elm-select"
            [ attribute "contenteditable" "true"
            , on "input" (Decode.map Changed decodeInput)
            , on "compositionend" (Decode.map Changed decodeCompositionEnd)
            , on "select" (Decode.map Changed decodeSelect)
            , on "pasteHTML" (Decode.map Pasted decodePasteHtml)
            ]
            (Doc.toHtml model.doc)
        ]


debug : Model -> Html Msg
debug { events } =
    Html.ul [] (List.map (Html.li [] << List.singleton << Html.text << Debug.toString) events)


main : Program () Model Msg
main =
    Browser.document
        { init = init
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



-- event decoders


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


decodeCompositionEnd : Decoder Event
decodeCompositionEnd =
    Decode.map InsertText (Decode.field "data" Decode.string)


decodeSelect : Decoder Event
decodeSelect =
    Decode.map2 ChangeSelection
        (Decode.at [ "detail", "start", "offset" ] Decode.int)
        (Decode.at [ "detail", "end", "offset" ] Decode.int)


decodePasteHtml : Decoder RawHtml
decodePasteHtml =
    -- TODO: we could probably decode this to a document structure in this paste
    Decode.at [ "detail", "html" ] Decode.string
        |> Decode.map RawHtml
