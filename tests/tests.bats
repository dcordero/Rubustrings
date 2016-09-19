#!/usr/bin/env bats

@test "Validate file with no strings" {
    run ./rubustrings tests/suites/Localizable_with_no_strings.in

    [ "$output" = "`cat tests/suites/Localizable_with_no_strings.out`" ]
}

@test "Valid parameter fields" {
    run ./rubustrings tests/suites/Localizable_with_valid_params.in

    [ "$output" = "`cat tests/suites/Localizable_with_valid_params.out`" ]
}

@test "Invalid parameter fields" {
    run ./rubustrings tests/suites/Localizable_with_invalid_params.in

    [ "$output" = "`cat tests/suites/Localizable_with_invalid_params.out`" ]
}
