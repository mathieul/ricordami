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
    @index.internal_name.should == "data_source:uidx:all_ids"
  end

  it "adds a string to the index with #add" do
    @index.add("ze-id", "allo")
    Souvenirs.driver.smembers("data_source:uidx:all_ids").should == ["allo"]
  end

  it "also indices the hash index with #add if fields is not :id" do
    DataSource.attribute :domain
    other = subject.new(DataSource, [:name, :domain])
    other.add("ze-id", ["jobs", "apple.com"])
    Souvenirs.driver.smembers("data_source:uidx:all_name_domains").should == ["jobs:-:apple.com"]
    Souvenirs.driver.hget("data_source:hash:name_domain_to_id", "jobs:-:apple.com").should == "ze-id"
  end

  it "removes a string from the index with #rem" do
    @index.add("allo")
    @index.rem("allo")
    Souvenirs.driver.smembers("data_source:uidx:all_ids").should == []
  end

  it "returns the number of entries with #count" do
    5.times { |i| @index.add(i.to_s) }
    @index.count.should == 5
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
