module Souvenirs
  Error         = Class.new(StandardError)
  NotFound      = Class.new(Error)
  ModelInvalid  = Class.new(Error)
end
