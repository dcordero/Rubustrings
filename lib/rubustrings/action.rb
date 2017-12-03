
require 'colored'

module Rubustrings
  class Action

    def validate(filenames)
      abort 'No strings file provided' unless filenames
      filenames.each do |file_name|
        log_output(:info, '', 0, "Processing file: \"#{file_name}\"\n")
        result = validate_localizable_string_file file_name

        if result
          log_output(:result_success, file_name, 0, 'Strings file validated succesfully')
          exit 0
        else
          log_output(:result_error, file_name, 0, 'Some errors detected')
          exit 1
        end
      end
    end

    # Possible levels are :error, :result_error, :warning, :result_success, :info
    def log_output(level, file_name, line_number, message)
      message = message.chomp
      case level
      when :error
        puts "#{file_name}:#{line_number}: error: #{message}"
      when :warning
        puts "#{file_name}:#{line_number}: warning: #{message}"
      when :result_success
        puts "\nResult: ✓ #{message}".bold.green
      when :result_error
        puts "\nResult: ✘ #{message}".bold.red
      when :info
        puts message.to_s.blue
      end
    end

    def validate_localizable_string_file(file_name)
      file_data = open_and_read_file file_name
      cleaned_strings = remove_comments_and_empty_lines file_data

      return log_output(:error, file_name, 0, "no translations found in file: #{file_name}") if cleaned_strings.empty?

      validation_result = true
      cleaned_strings.each_line do |line|
        validation_result &= validate_translation_line file_name, line
      end
      validation_result
    end

    def add_line_numbers(file_data)
      line_num = 0
      result = ''
      file_data.each_line do |line|
        line_num += 1
        result += "#{line_num} #{line}"
      end
      result
    end

    def open_and_read_file(file_name)
      return nil unless File.exist?(file_name)

      begin
        File.open(file_name, 'rb:utf-16:utf-8').read
      rescue
        File.open(file_name, 'rb:utf-8:utf-8').read
      end
    end

    def remove_comments_and_empty_lines(file_data)
      multiline_comments_regex = %r{/\*.*?\*/}m
      empty_lines_regex = /^[1-9]\d* $\n/

      file_data_with_lines = add_line_numbers file_data
      file_data_with_lines.gsub(multiline_comments_regex, '').gsub(empty_lines_regex, '') if file_data
    end

    def validate_format(line)
      localizable_strings_format_regex = /^\"((?:\\.|[^\\"])*?)\"\s=\s\"((?:\\.|[^\\"])*?)\";/
      localizable_strings_format_regex.match line
    end

    def validate_special_characters(translation_key, translation_value)
      variables_regex = /%[hlqLztj]?[@%dDuUxXoOfeEgGcCsSpaAF]/
      key_variables = translation_key.scan(variables_regex)
      value_variables = translation_value.scan(variables_regex)

      key_variables.sort == value_variables.sort
    end

    def validate_special_beginning(translation_key, translation_value)
      beginning_regex = /^(?:\s|\n|\r)/

      return true unless translation_key =~ beginning_regex || translation_value =~ beginning_regex
      translation_key.chars.first == translation_value.chars.first
    end

    def validate_special_ending(translation_key, translation_value)
      ending_regex = /(?:\s|\n|\r)$/

      return true unless translation_key =~ ending_regex || translation_value =~ ending_regex
      translation_key.chars.last == translation_value.chars.last
    end

    def check_translation_length(translation_key, translation_value)
      translation_value.length / translation_key.length < 3
    end

    def validate_translation_line(file_name, line)
      line_number = 0

      empty_regex = /^\d+\s*\n?$/
      return true if empty_regex.match line

      numbered_line_regex = /^(\d+) (.*)/
      numbered_line_match = numbered_line_regex.match line

      return log_output(:error, file_name, line_number, 'internal error') unless numbered_line_match
      line_number = numbered_line_match[1]
      line = numbered_line_match[2]

      match = validate_format line
      return log_output(:error, file_name, line_number, "invalid format: #{line}") unless match

      match_key = match[1]
      match_value = match[2]

      log_output(:warning, file_name, line_number, "no translated string: #{line}") if match_value.empty?

      log_output(:warning, file_name, line_number, "translation significantly large: #{line}") unless check_translation_length match_key, match_value

      validation_special_characters = validate_special_characters match_key, match_value
      log_output(:error, file_name, line_number, "number of variables mismatch: #{line}") unless validation_special_characters

      validation_special_beginning = validate_special_beginning match_key, match_value
      log_output(:error, file_name, line_number, "beginning mismatch: #{line}") unless validation_special_beginning

      validation_special_ending = validate_special_ending match_key, match_value
      log_output(:error, file_name, line_number, "ending mismatch: #{line}") unless validation_special_ending

      validation_special_characters && validation_special_beginning && validation_special_ending
    end
  end
end
