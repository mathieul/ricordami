require "digest/sha1"

require "active_support/concern"
require "active_support/core_ext/hash/slice"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/object/blank"
require "active_model"
require "active_model/naming"
require "active_model/conversion"
require "active_model/attribute_methods"
require "redis"

module Ricordami
  extend self
end

require "ricordami/exceptions"
require "ricordami/configuration"
require "ricordami/connection"
require "ricordami/has_attributes"
require "ricordami/has_indices"
require "ricordami/is_lockable"
require "ricordami/is_persisted"
require "ricordami/is_retrievable"
require "ricordami/model"
