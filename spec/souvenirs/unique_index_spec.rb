require "spec_helper"

describe Souvenirs::UniqueIndex do
  subject { Souvenirs::UniqueIndex }

  before(:each) do
    create_constant("DataSource")
    DataSource.attribute :name
    @index = subject.new(DataSource, :id)
  end

  it "is initialized with an owner type, a name and the fields to be unique" do
    @index.owner_type.should == "data_source"
    @index.fields.should == [:id]
    @index.name.should == "all_ids"
  end

  it "returns its internal index name with #internal_name" do
    @index.internal_name.should == "_index:data_source:all_ids"
  end

  it "adds a string to the index with #add" do
    @index.add("allo")
    Souvenirs.driver.smembers("_index:data_source:all_ids").should == ["allo"]
  end

  it "removes a string from the index with #rem" do
    @index.add("allo")
    @index.rem("allo")
    Souvenirs.driver.smembers("_index:data_source:all_ids").should == []
  end

  it "returns all the strings from the index with #all" do
    %w(allo la terre).each { |v| @index.add(v) }
    @index.all.should =~ ["allo", "la", "terre"]
  end

  it "returns if a string already exists with #include?" do
    %w(allo la terre).each { |v| @index.add(v) }
    @index.should include("terre")
    @index.should_not include("earth")
  end

  it "serializes object fields into a string with #package_fields" do
    index = DataSource.index :unique => [:id, :name]
    ds = DataSource.create(:id => "zeid", :name => "oldname")
    ds.name = "newname"
    index.package_fields(ds).should == "zeid:-:newname"
    index.package_fields(ds, :previous_value => true).should == "zeid:-:oldname"
  end

  it "returns nil if there is no value to serialize with #package_fields" do
    DataSource.attribute :first
    DataSource.attribute :second
    index = DataSource.index :unique => [:first, :second]
    ds = DataSource.create(:first => "un", :second => "deux")
    index.package_fields(ds, :previous_value => true).should be_nil
  end

  it "serializes persisted value of object fields into a string with #package_fields" do
    DataSource.attribute :name
    index = DataSource.index :unique => [:name]
    ds = DataSource.create(:name => "blah")
    index.package_fields(ds, :for_deletion => true).should == "blah"
  end
end
