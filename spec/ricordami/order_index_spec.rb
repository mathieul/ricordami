require "spec_helper"
require "ricordami/order_index"

describe Ricordami::OrderIndex do
  subject { Ricordami::OrderIndex }

  before(:each) do
    create_constant("Person")
    Person.attribute :age
    @index = subject.new(Person, :age)
  end
  let(:index) { @index }

  it "is initialized with a model, a name and a field" do
    index.model.should == Person
    index.field.should == :age
    index.name.should == :o_age
  end

  it "adds the id to the order index with #add" do
    pending
    index.add("3", "VALUE")
    Ricordami.redis.smembers("Person:idx:first_name:VkFMVUU=").should == ["3"]
  end

  it "removes the id from the order index with #rem" do
    pending
    index.add("1", "VALUE")
    index.add("2", "VALUE")
    index.rem("1", "VALUE")
    Ricordami.redis.smembers("Person:idx:first_name:VkFMVUU=").should == ["2"]
  end

  it "returns the redis command to remove the value from the index when return_command is true" do
    pending
    commands = index.rem("1", "VALUE", true)
    commands.should == [[:srem, ["Person:idx:first_name:VkFMVUU=", "1"]]]
  end
end
