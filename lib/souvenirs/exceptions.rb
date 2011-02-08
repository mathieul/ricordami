module Souvenirs
  Error                   = Class.new(StandardError)
  NotFound                = Class.new(Error)
  ModelInvalid            = Class.new(Error)
  AttributeNotSupported   = Class.new(Error)
  ReadOnlyAttribute       = Class.new(Error)
  WriteToDbFailed         = Class.new(Error)
  InvalidIndexDefinition  = Class.new(Error)
  ModelHasBeenDeleted     = Class.new(Error)
end
