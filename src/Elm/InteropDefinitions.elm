module InteropDefinitions exposing (Flags, FromElm(..), ToElm(..), interop)

import Json.Encode
import Json.Decode
import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder, optional, required)
import Todos exposing (Todo, TodoStatus(..))

interop :
    { toElm : Decoder ToElm
    , fromElm : Encoder FromElm
    , flags : Decoder Flags
    }
interop =
    { toElm = toElm
    , fromElm = fromElm
    , flags = flags
    }

type FromElm
    = UpdateTodos (List Todo)


type ToElm
    = AuthenticatedUser User


type alias User =
    { username : String }


type alias Flags =
    { todos : String }

fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vUpdateTodos value ->
            case value of
                UpdateTodos todos ->
                    vUpdateTodos todos
        )
        |> TsEncode.variantTagged "updateTodos"
            (TsEncode.object [ required "todos" identity (TsEncode.list todoEncoder) ])
        |> TsEncode.buildUnion


toElm : Decoder ToElm
toElm =
    TsDecode.discriminatedUnion "tag"
        [ ( "authenticatedUser"
          , TsDecode.map AuthenticatedUser
                (TsDecode.map User
                    (TsDecode.field "username" TsDecode.string)
                )
          )
        ]


flags : Decoder Flags
flags =
    TsDecode.map Flags (TsDecode.field "todos" TsDecode.string)

-- todoDecoder : Decoder Todo
-- todoDecoder =
--     TsDecode.map5 Todo
--         (TsDecode.field "id" TsDecode.int)
--         (TsDecode.field "name" TsDecode.string)
--         (TsDecode.field "workedTime" TsDecode.float)
--         (TsDecode.field "previousWorkedTime" TsDecode.float)
--         (TsDecode.field "status" todoStatusDecoder)

-- todoStatusDecoder : Decoder TodoStatus
-- todoStatusDecoder =
--     TsDecode.stringUnion
--         [ ( "info", Active )
--         , ( "warning", Incomplete )
--         , ( "error", Completed )
--         ]

todoEncoder : Encoder Todo
todoEncoder =
    TsEncode.object
        [ required "id" .id TsEncode.int
        , required "name" .name TsEncode.string
        , required "workedTime" .workedTime TsEncode.float
        , required "previousWorkedTime" .previousWorkedTime TsEncode.float
        , required "status" .status todoStatusEncoder
        ]

todoStatusEncoder : Encoder TodoStatus
todoStatusEncoder =
    TsEncode.union
        (\vActive vIncomplete vCompleted value ->
            case value of
                Active ->
                    vActive
                Incomplete ->
                    vIncomplete
                Completed ->
                    vCompleted
        )
        |> TsEncode.variantLiteral (Json.Encode.string "active")
        |> TsEncode.variantLiteral (Json.Encode.string "incomplete")
        |> TsEncode.variantLiteral (Json.Encode.string "completed")
        |> TsEncode.buildUnion
