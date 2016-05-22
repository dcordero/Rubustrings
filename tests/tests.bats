#!/usr/bin/env bats

@test "Validate file with no strings" {
    run ./rubustrings tests/suites/Localizable_with_no_strings.in

    [ "$output" = "`cat tests/suites/Localizable_with_no_strings.out`" ]
}

