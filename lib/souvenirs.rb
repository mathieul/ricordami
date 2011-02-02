require "digest/sha1"

require "active_support/concern"
require "active_support/core_ext/hash/slice"
require "active_support/core_ext/hash/keys"
require "active_model"
require "redis"

module Souvenirs
  extend self
end

require "souvenirs/exceptions"
require "souvenirs/configuration"
require "souvenirs/connection"
require "souvenirs/attribute"
require "souvenirs/has_attributes"
require "souvenirs/model"
