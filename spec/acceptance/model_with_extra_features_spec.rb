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
end

feature "Model extra features" do
  before(:each) do
    Souvenirs.configure do |c|
      c.redis_host  = "127.0.0.1"
      c.redis_port  = 6379
      c.redis_db    = 1
      c.thread_safe = false
    end
  end

  scenario "observers" do
    messages = []
    observer = Singer.observe do |event, info|
      messages << [event, info]
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
    observer.join
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
