#!/usr/bin/env ruby

require "rubygems"
require "ricordami"

Ricordami.configure do |config|
  config.redis_host = "127.0.0.1"
  config.redis_port = 6379
  config.redis_db   = 0
end

class Singer
  include Ricordami::Model
  model_can :have_relationships
  attribute :name

  references_many :songs
end

class Song
  include Ricordami::Model
  model_can :have_relationships
  attribute :title

  referenced_in :singer
end

bashung = Singer.create(:name => "Alain Bashung")
bashung.songs  # => []
osez = bashung.songs.build(:title => "Osez Josephine")
osez.save
gaby = bashung.songs.create(:title => "Vertiges de l'Amour")
p bashung.songs.map(&:title)  # => ["Osez Josephine", "Vertiges de l'Amour"]
p gaby.singer_id == bashung.id  # => true

padam = Song.create(:title => "Padam")
benjamin = padam.create_singer(:name => "Benjamin Biolay")
p benjamin.songs.map(&:title)  # => "Padam"
