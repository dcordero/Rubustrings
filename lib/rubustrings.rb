
require 'rubustrings/action'

# The main Rubustrings driver
module Rubustrings
  class << self
    def validate(filenames)
      Action.new.validate(filenames)
    end
  end
end
