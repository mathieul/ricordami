require "spec_helper"
require "ricordami/order_index"

describe Ricordami::OrderIndex do
  subject { Ricordami::OrderIndex }

  before(:each) do
    create_constant("Person")
    Person.attribute :age, :type => :integer
    @index = subject.new(Person, :age)
  end
  let(:index) { @index }

  it "is initialized with a model, a name and a field" do
    index.model.should == Person
    index.field.should == :age
    index.name.should == :o_age
  end

  it "raises an error if the field type is not an integer or a float" do
    Person.attribute :name
    lambda {
      subject.new(Person, :name)
    }.should raise_error(Ricordami::TypeNotSupported)
  end

  it "adds the id with its value to the order index with #add" do
    index.add("3", 42)
    Ricordami.redis.zrange("Person:odx:age", 0, -1, :with_scores => true).should == ["3", "42"]
  end

  it "removes the id from the order index with #rem" do
    index.add("1", 12)
    index.add("2", 42)
    index.rem("1", 12)
    Ricordami.redis.zrange("Person:odx:age", 0, -1, :with_scores => true).should == ["2", "42"]
  end

  it "returns the redis command to remove the id from the index when return_command is true" do
    commands = index.rem("7", 42, true)
    commands.should == [[:zrem, ["Person:odx:age", "7"]]]
  end
end
