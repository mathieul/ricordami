#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "ricordami"

Ricordami.redis.select(15)
Ricordami.redis.flushdb

class Person
  include Ricordami::Model
  attribute :name, :default => "First name, Last name"
  attribute :sex,  :indexed => :value
  attribute :age,  :type => :integer
end

zhanna = Person.create(:name => "Zhanna", :sex => "Female", :age => 29)
p :id, zhanna.id            # => "1"
p :[], Person[1].name       # => "Zhanna"
p :get, Person.get(1).name  # => "Zhanna"
