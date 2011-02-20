module Souvenirs
  Error                   = Class.new(StandardError)
  NotFound                = Class.new(Error)
  AttributeNotSupported   = Class.new(Error)
  ReadOnlyAttribute       = Class.new(Error)
  InvalidIndexDefinition  = Class.new(Error)
  ModelHasBeenDeleted     = Class.new(Error)
  TypeNotSupported        = Class.new(Error)
  MissingIndex            = Class.new(Error)
  LockTimeout             = Class.new(Error)
  EventNotSupported       = Class.new(Error)
end
