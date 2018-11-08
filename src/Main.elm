module Main exposing (main)

import Browser
import Html


main : Program () () ()
main =
    Browser.document
        { init = \_ -> ( (), Cmd.none )
        , update = \_ _ -> ( (), Cmd.none )
        , view = \_ -> { title = "Elm Edit", body = [ Html.text "hey" ] }
        , subscriptions = \_ -> Sub.none
        }
