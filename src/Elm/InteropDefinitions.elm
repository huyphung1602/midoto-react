module InteropDefinitions exposing (Flags, FromElm(..), ToElm(..), interop)

import Json.Encode
import TsJson.Decode as TsDecode exposing (Decoder)
import TsJson.Encode as TsEncode exposing (Encoder, optional, required)


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
    = UpdateCount Int


type ToElm
    = AuthenticatedUser User


type alias User =
    { username : String }


type alias Flags =
    { count : Int }


fromElm : Encoder FromElm
fromElm =
    TsEncode.union
        (\vUpdateCount value ->
            case value of
                UpdateCount int ->
                    vUpdateCount int
        )
        |> TsEncode.variantTagged "updateCount"
            (TsEncode.object [ required "count" identity TsEncode.int ])
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
    TsDecode.map Flags (TsDecode.field "count" TsDecode.int)
