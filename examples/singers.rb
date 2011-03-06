#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "rubygems"
require "ricordami"

Ricordami.redis.select(15)
Ricordami.redis.flushdb

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
p :songs, bashung.songs.map(&:title)  # => ["Osez Josephine", "Vertiges de l'Amour"]
p :singer_id, gaby.singer_id == bashung.id  # => true

padam = Song.create(:title => "Padam")
p :padam, padam
benjamin = padam.build_singer(:name => "Benjamin Biolay")
p :benjamin, benjamin
p :songs, benjamin.songs.map(&:title)  # => "Padam"
