require 'minitest/autorun'
require 'rubustrings'

class RubustringsTest < Minitest::Test
  def test_localizable_missing_semicolon
    output = File.read('test/suites/Localizable_missing_semicolon.out')

    out, err = capture_io do
      Rubustrings.validate(['test/suites/Localizable_missing_semicolon.in'])
    end

    assert_match output, out
    assert_empty err
  end

  def test_localizable_with_no_strings
    output = File.read('test/suites/Localizable_with_no_strings.out')

    out, err = capture_io do
      Rubustrings.validate(['test/suites/Localizable_with_no_strings.in'])
    end

    assert_match output, out
    assert_empty err
  end

  def test_localizable_beginning_mismatch
    output = File.read('test/suites/Localizable_beginning_mismatch.out')

    out, err = capture_io do
      Rubustrings.validate(['test/suites/Localizable_beginning_mismatch.in'])
    end

    assert_match output, out
    assert_empty err
  end

  def test_localizable_number_of_variables_mismatch
    output = File.read('test/suites/Localizable_number_of_variables_mismatch.out')

    out, err = capture_io do
      Rubustrings.validate(['test/suites/Localizable_number_of_variables_mismatch.in'])
    end

    assert_match output, out
    assert_empty err
  end
end
