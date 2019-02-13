module Doc exposing (Attr, Doc, fromString, sampleDoc, toHtml)

import Html exposing (Html)


type Doc
    = Doc (List ( Char, List Attr ))


type Attr
    = Bold
    | Italic


sampleDoc : Doc
sampleDoc =
    Doc
        [ ( 'H', [ Bold ] )
        , ( 'e', [ Bold ] )
        , ( 'y', [ Bold ] )
        , ( ' ', [] )
        , ( 'w', [ Italic ] )
        , ( 'h', [ Italic ] )
        , ( 'a', [ Italic ] )
        , ( 't', [ Italic ] )
        , ( '\'', [ Italic ] )
        , ( 's', [ Italic ] )
        , ( ' ', [ Italic ] )
        , ( 'u', [ Italic ] )
        , ( 'p', [ Italic ] )
        , ( '?', [ Italic ] )
        ]


fromString : String -> Doc
fromString unstyled =
    unstyled
        |> String.toList
        |> List.map (\c -> ( c, [] ))
        |> Doc


toHtml : Doc -> List (Html msg)
toHtml (Doc chars) =
    List.map (\( c, attrs ) -> style c attrs) chars


style : Char -> List Attr -> Html msg
style c attrs =
    case attrs of
        [] ->
            Html.text (String.fromList [ c ])

        Bold :: rest ->
            Html.strong [] [ style c rest ]

        Italic :: rest ->
            Html.em [] [ style c rest ]
