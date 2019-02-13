module Selection exposing (Selection, end, init, isPoint, start)


type Selection
    = Selection Int Int


init : Int -> Int -> Selection
init start_ end_ =
    Selection (min start_ end_) (max start_ end_)


start : Selection -> Int
start (Selection start_ _) =
    start_


end : Selection -> Int
end (Selection _ end_) =
    end_


isPoint : Selection -> Bool
isPoint (Selection start_ end_) =
    start_ == end_
