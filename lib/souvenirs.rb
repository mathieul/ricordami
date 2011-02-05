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
require "simple_uuid"

module Souvenirs
  extend self
end

require "souvenirs/exceptions"
require "souvenirs/configuration"
require "souvenirs/connection"
require "souvenirs/has_attributes"
require "souvenirs/has_indices"
require "souvenirs/can_be_persisted"
require "souvenirs/can_be_queried"
require "souvenirs/can_be_validated"
require "souvenirs/model"
