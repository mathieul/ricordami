require "spec_helper"

describe Souvenirs::Index do
  subject { Souvenirs::Index }

  before(:all) do
    DataSource = Class.new
  end

  before(:each) do
    @index = subject.new(DataSource, :name)
  end

  it "is initialized with an owner type and a name" do
    @index.owner_type.should == "data_source"
    @index.name.should == "name"
  end

  it "returns its internal index name with #internal_name" do
    @index.internal_name.should == "_index:data_source:name"
  end

  it "adds a string to the index with #add" do
    @index.add("allo")
    Souvenirs.driver.smembers("_index:data_source:name").should == ["allo"]
  end

  it "removes a string from the index with #rem" do
    @index.add("allo")
    @index.rem("allo")
    Souvenirs.driver.smembers("_index:data_source:name").should == []
  end

  it "returns all the strings from the index with #all" do
    %w(allo la terre).each { |v| @index.add(v) }
    @index.all.should =~ ["allo", "la", "terre"]
  end
end
