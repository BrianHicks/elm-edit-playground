module Main exposing (main)

import Browser
import Doc exposing (Doc)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Selection exposing (Selection)


type alias Model =
    { selection : Selection
    , doc : Doc
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selection = Selection.init 0 0
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
    case msg of
        Changed (InsertText string) ->
            ( { model | doc = Doc.insertAt (Selection.start model.selection) string model.doc }
            , Cmd.none
            )

        Changed (ChangeSelection start end) ->
            ( { model | selection = Selection.init start end }
            , Cmd.none
            )

        Changed DeleteBackward ->
            ( { model | doc = Doc.delete (Selection.start model.selection) model.doc }
            , Cmd.none
            )

        Changed DeleteForward ->
            ( { model | doc = Doc.delete (Selection.start model.selection + 1) model.doc }
            , Cmd.none
            )

        Pasted _ ->
            -- TODO!
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    main_
        []
        [ p [] [ text (Debug.toString model) ]
        , node "elm-select"
            [ attribute "contenteditable" "true"
            , on "input" (Decode.map Changed decodeInput)
            , on "compositionend" (Decode.map Changed decodeCompositionEnd)
            , on "select" (Decode.map Changed decodeSelect)
            , on "pasteHTML" (Decode.map Pasted decodePasteHtml)
            , Html.Attributes.map Changed <| Html.Events.preventDefaultOn "keydown" decodeKeyDown
            ]
            (Doc.toHtml model.doc)
        ]


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \model ->
                { title = "Elm Edit"
                , body = [ view model ]
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


decodeKeyDown : Decoder ( Event, Bool )
decodeKeyDown =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\key ->
                case key of
                    "Backspace" ->
                        Decode.succeed ( DeleteBackward, True )

                    "Delete" ->
                        Decode.succeed ( DeleteForward, True )

                    _ ->
                        Decode.fail "I'm only for deletions!"
            )
