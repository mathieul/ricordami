#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "pp"
require "rubygems"
require "ricordami"

module ValueGenerator
  extend self

  CALL_TYPES = ["pots", "voip"]
  NETWORKS = ["att", "qwest", "level3"]

  def phone_number
    "xxxxxxxxxx".split('').map { rand(10) }.join
  end

  def call_type
    CALL_TYPES[rand(CALL_TYPES.length)]
  end

  def networks
    NETWORKS[rand(NETWORKS.length)]
  end
end

Ricordami.redis.select(15)
Ricordami.redis.flushdb

class Tenant
  include Ricordami::Model
  model_can :be_queried, :be_validated, :have_relationships

  attribute :name, :read_only => true
  index :unique => :name, :get_by => true

  references_many :calls, :alias => :owner, :dependent => :delete

  validates_presence_of   :name
  validates_uniqueness_of :name
end

class Call
  include Ricordami::Model
  model_can :be_queried, :be_validated, :have_relationships

  attribute :ani,       :indexed => :value
  attribute :dnis,      :indexed => :value
  attribute :call_type, :indexed => :value
  attribute :network,   :indexed => :value
  attribute :seconds, :type => :integer

  referenced_in :tenant, :as => :owner

  validates_presence_of  :call_type, :seconds, :owner_id
  validates_inclusion_of :call_type, :in => ["pots", "voip"]
  validates_inclusion_of :network,   :in => ["att", "qwest", "level3"]
end

tenants = %w(mycompany blah foo bar sowhat hereitgoesagain).map { |name| Tenant.create(:name => name) }

12.times do |i|
  t = tenants[rand(tenants.length)]
  t.calls.create(:ani => "6501234567",
                 :dnis => ValueGenerator.phone_number,
                 :call_type => ValueGenerator.call_type,
                 :network => ValueGenerator.networks,
                 :seconds => 10 * i)
end

123.times do |i|
  t = tenants[rand(tenants.length)]
  t.calls.create(:ani => ValueGenerator.phone_number,
                 :dnis => ValueGenerator.phone_number,
                 :call_type => "voip",
                 :network => "level3",
                 :seconds => 10 + rand(3600))
end

t = tenants[rand(tenants.length)]
t.calls.create(:ani => "you-found@me", :dnis => "911", :call_type => "voip", :network => "qwest", :seconds => 42)

50.times do |i|
  t = tenants.first
  t.calls.create(:ani => "4081234567",
                 :dnis => ValueGenerator.phone_number,
                 :call_type => "pots",
                 :network => "att",
                 :seconds => 10 + rand(3600))
end

puts <<EOC
?? What is the total number of seconds of the phone calls made from the phone number 650 123 4567?
EOC
seconds = Call.where(:ani => "6501234567").inject(0) { |sum, call| sum + call.seconds }
puts "  => seconds = #{seconds} (should be 780)"

puts "?? What are the VoIP calls from ani 'you-found@me' that didn't go through Level3 network?"
calls = Call.where(:call_type => "voip", :ani => "you-found@me").not(:network => "level3").all
puts "  => #{calls.inspect}"

puts <<EOC
?? What are the calls for tenant "mycompany" that went through AT&amp;T's network or originated from ANI 408 123 4567? but were not VoIP calls?
EOC
mycompany = Tenant.get_by_name("mycompany")
calls = mycompany.calls.any(:ani => "4081234567", :network => "att").not(:call_type => "voip")
puts "  => #{calls.count} calls (should be 50)"
puts "  => first page of 10:"
pp calls.paginate(:page => 1, :per_page => 10)
