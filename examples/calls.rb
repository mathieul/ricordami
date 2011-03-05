#!/usr/bin/env ruby
#$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "ricordami"

Ricordami.configure do |config|
  config.redis_host = "127.0.0.1"
  config.redis_port = 6379
  config.redis_db   = 15
end
Ricordami.driver.flushdb

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

t = Tenant.create(:name => "mycompany")
t.calls.create(:ani => "6501234567", :dnis => "911", :call_type => "pots", :network => "qwest", :seconds => 42)
# TODO: create more calls

puts <<EOC
?? What is the total number of seconds of the phone calls made from the phone number 650 123 4567?
EOC
seconds = Call.where(:ani => "6501234567").inject(0) { |sum, call| sum + call.seconds }
puts "  => seconds = #{seconds}"

puts "?? What are the VoIP calls that didn't go through Level3 network?"
calls = Call.where(:call_type => "voip").not(:network => "level3")
puts "  => #{calls.inspect}"

puts <<EOC
?? What are the calls for tenant "mycompany" that went through AT&amp;T's network or originated from ANI 408 123 4567? but were not VoIP calls?
EOC
mycompany = Tenant.get_by_name("mycompany")
calls = mycompany.calls.any(:ani => "4081234567", :network => "att").not(:call_type => "voip")
puts "  => #{calls.count} calls"
puts "  => first page of 10: #{calls.paginate(:page => 1, :per_page => 10).inspect}"
