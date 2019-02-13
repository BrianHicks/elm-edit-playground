module Doc exposing (Attr, Doc, delete, deleteSelection, fromString, insertAt, sampleDoc, toHtml)

import Html exposing (Html)
import Selection exposing (Selection)


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
        , ( 'w', [ Bold, Italic ] )
        , ( 'h', [ Bold, Italic ] )
        , ( 'a', [ Bold, Italic ] )
        , ( 't', [ Bold, Italic ] )
        , ( '\'', [ Bold, Italic ] )
        , ( 's', [ Bold, Italic ] )
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


insertAt : Int -> String -> Doc -> Doc
insertAt where_ text (Doc doc) =
    let
        prevAttrs =
            doc
                |> List.drop where_
                |> List.head
                |> Maybe.map Tuple.second
                |> Maybe.withDefault []

        prev =
            List.take where_ doc

        next =
            List.drop where_ doc

        current =
            text
                |> String.toList
                |> List.map (\c -> ( c, prevAttrs ))
    in
    Doc (prev ++ current ++ next)


delete : Int -> Doc -> Doc
delete where_ (Doc doc) =
    Doc (List.take (where_ - 1) doc ++ List.drop where_ doc)


deleteSelection : Selection -> Doc -> Doc
deleteSelection selection (Doc doc) =
    Doc (List.take (Selection.start selection) doc ++ List.drop (Selection.end selection) doc)
