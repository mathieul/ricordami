require "acceptance_helper"
require "souvenirs/can_be_observed"

class Singer
  include Souvenirs::Model
  include Souvenirs::CanBeObserved

  attribute :username
  attribute :email
  attribute :first_name
  attribute :last_name
  attribute :deceased, :default => "false", :indexed => :simple

  publish_when :created, :updated, :deleted
end

feature "Model extra features" do
  scenario "observers" do
    messages, observer = [], nil
    thread = Thread.new do
      observer = Singer.observe do |a_singer|
        a_singer.was_created { |info| messages << [:created, info] }
        a_singer.was_updated { |info| messages << [:updated, info] }
        a_singer.was_deleted { |info| messages << [:deleted, info] }
      end
    end

    serge = Singer.create(:username => "lucien", :email => "serge@gainsbourg.com",
                           :first_name => "Lucient", :last_name => "Gainsbourg")
    serge.first_name = "Serge"
    serge.save
    ben = Singer.create(:username => "ben", :email => "benjamin@biolay.com",
                        :first_name => "Benjamin", :last_name => "Biolay", :deceased => "false")
    alain = Singer.create(:username => "bashung", :email => "alain@bashung.com",
                          :first_name => "Alain", :last_name => "Bashung", :deceased => "true")
    alain.delete
    ben.delete
    serge.delete

    Singer.stop_observer(observer)
    thread.join

    messages.should == [
      [:created, {:id => "1"}],
      [:updated, {:id => "1", :first_name => ["Lucien", "Serge"]}],
      [:created, {:id => "2"}],
      [:created, {:id => "3"}],
      [:updated, {:id => "1", :last_name => ["Gainsbourg", "Gainsbare"], :deceased => ["false", "true"]}],
      [:deleted, {:id => "3"}],
      [:deleted, {:id => "2"}],
      [:deleted, {:id => "1"}]
    ]
  end
end
