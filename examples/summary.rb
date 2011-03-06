#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "ricordami"

Ricordami::configure do |config|
  config.redis_host = "127.0.0.1"
  config.redis_port = 6379
  config.redis_db   = 15
end
Ricordami.redis.flushdb

class Singer
  include Ricordami::Model

  model_can :be_validated, :have_relationships

  attribute :name

  validates_presence_of :name
  validates_uniqueness_of :name

  references_many :songs
end

class Song
  include Ricordami::Model

  model_can :be_queried, :have_relationships

  attribute :title
  attribute :year, :indexed => :value

  index :unique => :title, :get_by => true

  referenced_in :singer
end

serge = Singer.create :name => "Gainsbourg"
jetaime = serge.songs.create :title => "Je T'Aime Moi Non Plus", :year => "1967"
jetaime.year = "1968"
p :changes, jetaime.changes  # => {:year => ["1967", "1968"]}
jetaime.save
["La Javanaise", "Melody Nelson", "Love On The Beat"].each do |name|
  serge.songs.create :title => name, :year => "1962"
end
Song.get_by_title("Melody Nelson").update_attributes(:year => "1971")
Song.get_by_title("Love On The Beat").update_attributes(:year => "1984")

p :count, Song.count  # => 4
p :all, Song.all.map(&:title)
p :where, Song.where(:year => "1971").map(&:title)  # => "Melody Nelson"
