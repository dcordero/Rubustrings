#!/usr/bin/env ruby

# Rubustrings
# A format validator for Localizable.strings files.
# The MIT License (MIT) Copyright (c) 2014 @dcordero
# https://github.com/dcordero/Rubustrings

%w[colored].each do |this_gem|
  begin
    require this_gem
  rescue LoadError
    abort "Please install the '#{this_gem}' gem."
  end
end

def open_and_read_file(file_name)
  File.open(file_name, 'rb:utf-16:utf-8').read if File.exist?(file_name)
end

def remove_comments_and_empty_lines(file_data)
  multiline_comments_regex = /\/\*.*?\*\//m
  empty_lines_regex = /^$\n/

  file_data.gsub(multiline_comments_regex, "").gsub(empty_lines_regex, "") if file_data
end

def validate_format(line)
  localizable_strings_format_regex = /^\"((?:\\.|[^\\"])*?)\"\s=\s\"((?:\\.|[^\\"])*?)\";/
  match = localizable_strings_format_regex.match line
end

def validate_special_characters(translation_key, translation_value)
  variables_regex = /%[hlqLztj]?[@%dDuUxXoOfeEgGcCsSpaAF]/
  key_variables = translation_key.scan(variables_regex) 
  value_variables = translation_value.scan(variables_regex) 

  return key_variables.sort == value_variables.sort
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

def validate_translation_line(line)
  match = validate_format line
  return print "✘ Error, invalid format: #{line}".red unless match

  print "⊗ Warning, no translated string: #{line}".yellow unless match[2].length > 0

  print "⊗ Warning, translation significantly large: #{line}".yellow unless check_translation_length match[1], match[2]

  validation_special_characters = validate_special_characters match[1],match[2]
  print "✘ Error, number of variables mismatch: #{line}".red unless validation_special_characters

  validation_special_beginning = validate_special_beginning match[1],match[2]
  print "✘ Error, beginning mismatch: #{line}".red unless validation_special_beginning

  validation_special_ending = validate_special_ending match[1],match[2]
  print "✘ Error, ending mismatch: #{line}".red unless validation_special_ending

  return validation_special_characters && validation_special_beginning && validation_special_ending
end

file_name = ARGV[0]
file_data = open_and_read_file file_name
cleaned_strings = remove_comments_and_empty_lines file_data

if !cleaned_strings or cleaned_strings.empty?
  puts "✘ Error, no translations found in file: #{file_name}".red
  exit(1)
end

validation_result = true
cleaned_strings.each_line do |line|
  validation_result &= validate_translation_line line
end
exit validation_result
