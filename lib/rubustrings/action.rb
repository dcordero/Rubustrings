
require 'colored'

module Rubustrings
  class Action

    def validate(filenames, only_format)
      abort 'No strings file provided' unless filenames
      filenames.each do |file_name|
        log_output(:info, '', 0, "Processing file: \"#{file_name}\"\n")
        result = validate_localizable_string_file file_name, only_format

        if result
          log_output(:result_success, file_name, 0, 'Strings file validated succesfully')
          return true
        else
          log_output(:result_error, file_name, 0, 'Some errors detected')
          return false
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

    def validate_localizable_string_file(file_name, only_format) 
      file_data = open_and_read_file file_name
      cleaned_strings = remove_comments_and_empty_lines file_data

      return log_output(:error, file_name, 0, "no translations found in file: #{file_name}") if cleaned_strings.empty?

      validation_result = true
      cleaned_strings.each_line do |line|
        validation_result &= validate_translation_line file_name, line, only_format
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
      # Remove %% to avoid ambiguous scenarios with adjacent formats like "%s%%s"
      translation_key = translation_key.gsub("%%", " ")
      translation_value = translation_value.gsub("%%", " ")

      variables_regex = /\x25(?:([1-9]\d*)\$|\(([^\)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?(hh|ll|[hlLzjt])?([b-fiosuxX@])/
      position_index = 0
      length_index = 7
      format_index = 8

      # sort by according to parameter field, if specified
      key_variables = translation_key.scan(variables_regex).stable_sort_by{ |r| r[position_index].to_i }
      value_variables = translation_value.scan(variables_regex).stable_sort_by{ |r| r[position_index].to_i }

      return true unless key_variables.any? || value_variables.any?
      return false unless key_variables.count == value_variables.count

      # we should not have any parameter fields in the keys
      return false unless key_variables.last[position_index] == nil

      # if we do have parameter fields, we need to include all of them
      if value_variables[0][position_index] != nil
        return false unless value_variables.last[position_index] != nil
        validation_result = true
        value_variables.each_with_index { |v, idx|
          if v[position_index].to_i != idx + 1
            validation_result = false
          end
        }
        return false unless validation_result
      else
        return false unless value_variables.last[position_index] == nil
      end

      # remove parameter field
      key_variables = key_variables.map{ |v| [v[length_index], v[format_index]] }
      value_variables = value_variables.map{ |v| [v[length_index], v[format_index]] }
      key_variables == value_variables
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

    def validate_translation_line(file_name, line, only_format)
      line_number = 0

      empty_regex = /^\d+\s*\n?$/
      return true if empty_regex.match line

      numbered_line_regex = /^(\d+) (.*)/
      numbered_line_match = numbered_line_regex.match line

      return log_output(:error, file_name, line_number, 'internal error') unless numbered_line_match
      line_number = numbered_line_match[1]
      line = numbered_line_match[2]

      # skip # character, single line and multi line comments.
      comments_regex = /(?:#[^\n]*|\/\/[^\n]*|\/\*(?:(?!\*\/).)*\*\/)/
      return true if comments_regex.match line
      
      match = validate_format line
      return log_output(:error, file_name, line_number, "invalid format: #{line}") unless match

      return true if only_format

      match_key = match[1]
      match_value = match[2]

      log_output(:warning, file_name, line_number, "no translated string: #{line}") if match_value.empty?

      log_output(:warning, file_name, line_number, "translation significantly large: #{line}") unless check_translation_length match_key, match_value

      validation_special_characters = validate_special_characters match_key, match_value
      log_output(:error, file_name, line_number, "variables mismatch: #{line}") unless validation_special_characters

      validation_special_beginning = validate_special_beginning match_key, match_value
      log_output(:error, file_name, line_number, "beginning mismatch: #{line}") unless validation_special_beginning

      validation_special_ending = validate_special_ending match_key, match_value
      log_output(:error, file_name, line_number, "ending mismatch: #{line}") unless validation_special_ending

      validation_special_characters && validation_special_beginning && validation_special_ending
    end
  end
end

module Enumerable
  def stable_sort
    sort_by.with_index { |x, idx| [x, idx] }
  end

  def stable_sort_by
    sort_by.with_index { |x, idx| [yield(x), idx] }
  end
end
