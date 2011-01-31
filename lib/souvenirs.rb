require "digest/sha1"

require "active_support/concern"
require "active_support/core_ext/hash/slice"
require "active_model"

module Souvenirs
  extend self
end

require "souvenirs/exceptions"
require "souvenirs/configuration"
require "souvenirs/attributes"
require "souvenirs/model"
