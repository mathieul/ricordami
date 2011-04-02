require "acceptance_helper"
require "ricordami/can_be_queried"
require "ricordami/can_have_relationships"

class Movie
  include Ricordami::Model
  model_can :have_relationships, :be_queried

  attribute :title
  attribute :director
  attribute :year

  references_many :reviews
  references_many :people, :through => :reviews, :as => :reviewers
end

class Person
  include Ricordami::Model
  model_can :have_relationships, :be_queried
  
  attribute :name
  attribute :age
  attribute :sex
  attribute :town

  references_many :reviews
  references_many :movies, :through => :reviews
end

class Review
  include Ricordami::Model
  model_can :have_relationships, :be_queried
  
  attribute :note

  referenced_in :movie
  referenced_in :person
end

module RelationshipsAndQueriesHelper
  def load_data
    [Movie, Person, Review].each do |klass|
      file = File.expand_path("../../data/#{klass.to_s.downcase}.json", __FILE__)
      json = File.read(file)
      items = ActiveSupport::JSON.decode(json)
      items.each do |attributes|
        res = klass.create(attributes.symbolize_keys)
        ap [klass, res]
      end
    end
  end
end

feature "Relationships and queries" do
  include RelationshipsAndQueriesHelper

  before(:all) do
    Ricordami.redis.select 8
    Ricordami.redis.flushdb
    load_data
  end

  scenario "test" do
    Ricordami.redis.select 8
    ap Movie.all

    Movie.count.should == 1
    Person.count.should == 1
    Review.count.should == 1
  end
end
