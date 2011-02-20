require "spec_helper"
require "souvenirs/can_be_observed"

describe Souvenirs::CanBeObserved do
  uses_constants("Token")

  before(:each) do
    class Token
      include Souvenirs::CanBeObserved
      attribute :queue
      attribute :skill
    end
  end

  describe "class method #publish_when" do
    it "raises an error if an event is unknown" do
      lambda {
        Token.publish_when(:unknown)
      }.should raise_error(Souvenirs::EventNotSupported)
    end

    it "can request to publish when an instance is created" do
      Token.publish_when(:created)
      Token.published.should == [:created]
    end

    it "can request to publish when an instance is updated" do
      Token.publish_when(:updated)
      Token.published.should == [:updated]
    end

    it "can request to publish when an instance is deleted" do
      Token.publish_when(:deleted)
      Token.published.should == [:deleted]
    end

    it "can request to publish different events" do
      Token.publish_when(:created, :updated, :deleted)
      Token.published.should =~ [:created, :updated, :deleted]
    end
  end

  describe "observe creations with #observe" do
    it "raises an error if called without a block" do
      lambda {
        Token.observe(:created)
      }.should raise_error(ArgumentError)
    end

    it "can observe when an instance is created" do
      Thread.abort_on_exception = true
      listening = false
      Token.publish_when(:created)
      messages = []
      thread = Thread.new do
        Token.observe(:created) do |a_token|
          a_token.was_created do |info|
            info.should == {:id => "1"}
            messages << [:created, info]
            puts "before punsubscribe"
            Souvenirs.driver.punsubscribe("token.created")
            puts "after punsubscribe"
          end
          listening = true
        end
      end
      Thread.pass while !listening

      Redis.new.publish("token.created", "1")
      thread.join
      messages.should == [
        [:created, {:id => "1"}]
      ]
    end
  end
end
