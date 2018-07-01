module CliTests exposing (all)

import Cli
import Cli.Command as Command
import Expect exposing (Expectation)
import Test exposing (..)


all : Test
all =
    describe "synopsis"
        [ test "matching command" <|
            \() ->
                let
                    cli =
                        [ Command.build 123
                            |> Command.expectFlag "help"
                            |> Command.toCommand
                        ]
                in
                Cli.try cli [ "", "", "--help" ]
                    |> Expect.equal (Cli.Match 123)
        , test "non-matching command" <|
            \() ->
                let
                    cli =
                        [ Command.build 123
                            |> Command.expectFlag "help"
                            |> Command.toCommand
                        ]
                in
                Cli.try cli [ "", "" ]
                    |> Expect.equal (Cli.NoMatch [])
        , test "unknown flag" <|
            \() ->
                let
                    cli =
                        [ Command.build 123
                            |> Command.expectFlag "help"
                            |> Command.toCommand
                        ]
                in
                Cli.try cli [ "", "", "--unknown-flag" ]
                    |> Expect.equal (Cli.NoMatch [ "unknown-flag" ])
        ]
