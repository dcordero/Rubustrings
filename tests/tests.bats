#!/usr/bin/env bats

@test "Validate file with no strings" {
    run ./rubustrings tests/suites/Localizable_with_no_strings.in

    [ "$output" = "`cat tests/suites/Localizable_with_no_strings.out`" ]
}

@test "Validate file with missing semicolon" {
    run ./rubustrings tests/suites/Localizable_missing_semicolon.in

    [ "$output" = "`cat tests/suites/Localizable_missing_semicolon.out`" ]
}

