require "acceptance_helper"
require "ricordami/can_be_queried"
require "ricordami/can_have_relationships"
require "benchmark"

module RelationshipsAndQueriesHelper
  def load_data
    [Movie, Person, Review].each do |klass|
      seconds = measure do
        file = File.expand_path("../../data/#{klass.to_s.downcase}.json", __FILE__)
        json = File.read(file)
        items = ActiveSupport::JSON.decode(json)
        items.each do |attributes|
          res = klass.create(attributes.symbolize_keys)
        end
      end
      puts "#{klass.count} #{klass.to_s.pluralize} loaded in #{seconds} secs."
    end
  end

  def measure(&block)
    seconds = Benchmark.measure(&block).format("%r")[1..-2].to_f
    seconds.round(3)
  end
end

class Movie
  include Ricordami::Model
  model_can :have_relationships, :be_queried

  attribute :title
  attribute :director, :indexed => :value
  attribute :year, :type => :integer, :indexed => :value

  references_many :reviews
  references_many :people, :through => :reviews, :as => :reviewers
end

class Person
  include Ricordami::Model
  model_can :have_relationships, :be_queried
  
  attribute :name
  attribute :age, :type => :integer, :indexed => :value
  attribute :sex, :indexed => :value
  attribute :town, :indexed => :value

  references_many :reviews
  references_many :movies, :through => :reviews
end

class Review
  include Ricordami::Model
  model_can :have_relationships, :be_queried
  
  attribute :note, :type => :integer, :indexed => :value
  attribute :when, :indexed => :value

  referenced_in :movie
  referenced_in :person
end

feature "Relationships and queries" do
  include RelationshipsAndQueriesHelper

  before(:each) do
    pending
    load_data
  end

  scenario "querying movies and reviews" do
  end
end
