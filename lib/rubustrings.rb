
require 'rubustrings/action'

# The main Rubustrings driver
module Rubustrings
  class << self
    def validate(filenames, only_format = false)
      Action.new.validate(filenames, only_format)
    end
  end
end
