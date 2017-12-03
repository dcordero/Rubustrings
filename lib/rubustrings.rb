
require 'rubustrings/action'

module Rubustrings
  # The main Rubustrings driver
  class << self
    def validate(filenames)
      Action.new.validate(filenames)
    end
  end
end
