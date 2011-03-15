require "spec_helper"
require "ricordami/value_index"

describe Ricordami::ValueIndex do
  subject { Ricordami::ValueIndex }

  before(:each) do
    create_constant("Friend")
    Friend.attribute :first_name
    @index = subject.new(Friend, :first_name)
  end
  let(:index) { @index }

  it "is initialized with a model, a name and a field" do
    index.model.should == Friend
    index.field.should == :first_name
    index.name.should == :v_first_name
  end

  it "has a key name for each distinct value with #key_name_for_value" do
    index.key_name_for_value("VALUE").should == "Friend:idx:first_name:VkFMVUU="
  end

  it "adds the id to the index value with #add" do
    index.add("3", "VALUE")
    Ricordami.redis.smembers("Friend:idx:first_name:VkFMVUU=").should == ["3"]
  end

  it "removes the id from the index value with #rem" do
    index.add("1", "VALUE")
    index.add("2", "VALUE")
    index.rem("1", "VALUE")
    Ricordami.redis.smembers("Friend:idx:first_name:VkFMVUU=").should == ["2"]
  end

  it "returns the redis command to remove the value from the index when return_command is true" do
    commands = index.rem("1", "VALUE", true)
    commands.should == [[:srem, ["Friend:idx:first_name:VkFMVUU=", "1"]]]
  end
end
