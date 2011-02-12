require "spec_helper"
require "souvenirs/simple_index"

describe Souvenirs::SimpleIndex do
  subject { Souvenirs::SimpleIndex }

  before(:each) do
    create_constant("Friend")
    Friend.attribute :first_name
    @index = subject.new(Friend, :first_name)
  end
  let(:index) { @index }

  it "is initialized with an owner type, a name and a field" do
    index.owner_type.should == Friend
    index.field.should == :first_name
    index.name.should == :first_name
  end

  it "has a key name for each distinct value with #key_name_for_value" do
    index.key_name_for_value("VALUE").should == "Friend:idx:first_name:VkFMVUU="
  end
end
