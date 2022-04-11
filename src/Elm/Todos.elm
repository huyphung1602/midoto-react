module Todos exposing (Todo, TodoStatus(..))

type TodoStatus
    = Active
    | Incomplete
    | Completed

type alias Todo =
    { id : Int
    , name : String
    , workedTime : Float
    , previousWorkedTime : Float
    , status : TodoStatus
    }
