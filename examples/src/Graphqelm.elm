port module Graphqelm exposing (main)

import Cli
import Command exposing (with)
import Json.Decode exposing (..)
import Regex


cli : List (Command.Command InitMsg)
cli =
    [ Command.build PrintVersion
        |> Command.expectFlag "version"
        |> Command.toCommand
    , Command.build PrintHelp
        |> Command.expectFlag "help"
        |> Command.toCommand
    , Command.buildWithDoc FromUrl "generate files based on the schema at `url`"
        |> with (Command.requiredOperand "url")
        |> with baseOption
        |> with (Command.optionalOption "output")
        |> with (Command.optionalFlag "excludeDeprecated")
        |> with (Command.optionalListOption "header")
        |> Command.toCommand
    , Command.build FromFile
        |> with (Command.requiredOption "introspection-file")
        |> with baseOption
        |> with (Command.optionalOption "output")
        |> with (Command.optionalFlag "excludeDeprecated")
        |> Command.toCommand
    ]


baseModuleRegex : String
baseModuleRegex =
    "^[A-Z][A-Za-z_]*(\\.[A-Z][A-Za-z_]*)*$"


baseOption : Command.CliUnit (Maybe String) (Maybe String)
baseOption =
    Command.optionalOption "base"
        |> Command.validate
            (\maybeBaseModuleName ->
                case maybeBaseModuleName of
                    Just baseModuleName ->
                        if Regex.contains (Regex.regex baseModuleRegex) baseModuleName then
                            Command.Valid
                        else
                            Command.Invalid ("Must be of form /" ++ baseModuleRegex ++ "/")

                    Nothing ->
                        Command.Valid
            )


dummy : Decoder String
dummy =
    -- this is a workaround for an Elm compiler bug
    Json.Decode.string


type alias Flags =
    List String


type alias Model =
    ()


type alias Msg =
    ()


type InitMsg
    = PrintVersion
    | PrintHelp
    | NoOp
    | FromUrl String (Maybe String) (Maybe String) Bool (List String)
    | FromFile String (Maybe String) (Maybe String) Bool


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        msg =
            flags
                |> List.drop 2
                |> Cli.try cli

        toPrint =
            case msg |> Maybe.withDefault (Ok NoOp) of
                Ok PrintVersion ->
                    "You are on version 3.1.4"

                Ok PrintHelp ->
                    Cli.helpText "graphqelm" cli

                Ok NoOp ->
                    "\nNo matching command...\n\nUsage:\n\n"
                        ++ Cli.helpText "graphqelm" cli

                Ok (FromUrl url base outputPath excludeDeprecated headers) ->
                    "...fetching from url " ++ url ++ "\noptions: " ++ toString ( url, base, outputPath, excludeDeprecated, headers )

                Ok (FromFile file base outputPath excludeDeprecated) ->
                    "...fetching from file " ++ file ++ "\noptions: " ++ toString ( base, outputPath, excludeDeprecated )

                Err validationErrors ->
                    "Validation errors:\n\n" ++ toString validationErrors
    in
    ( (), print toPrint )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


port print : String -> Cmd msg


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
