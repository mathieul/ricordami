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

  it "returns its internal index name with #uidx_key_name" do
    @index.uidx_key_name.should == "data_source:uidx:all_ids"
  end

  it "returns its internal reference name with #ref_key_name" do
    @index.ref_key_name.should == "data_source:hash:id_to_id"
  end

  it "adds a string to the index with #add" do
    @index.add("ze-id", "allo")
    Souvenirs.driver.smembers("data_source:uidx:all_ids").should == ["allo"]
  end

  it "also indices the hash index with #add if fields is not :id and :get_by is true" do
    DataSource.attribute :domain
    other = subject.new(DataSource, [:name, :domain], :get_by => true)
    other.add("ze-id", ["jobs", "apple.com"])
    Souvenirs.driver.smembers("data_source:uidx:all_name_domains").should == ["jobs:-:apple.com"]
    Souvenirs.driver.hget("data_source:hash:name_domain_to_id", "jobs:-:apple.com").should == "ze-id"
  end

  it "doesn't index the has index with #add if :get_by is false or fields is :id" do
    one = subject.new(DataSource, :name)
    one.add("ze-id", "jobs")
    Souvenirs.driver.hexists("data_source:hash:name_to_id", "jobs").should be_false
    two = subject.new(DataSource, :id, :get_by => true)
    two.add("ze-id", "ze-id")
    Souvenirs.driver.hexists("data_source:hash:id_to_id", "ze-id").should be_false
    three = subject.new(DataSource, :name, :get_by => true)
    three.add("ze-id", "jobs")
    Souvenirs.driver.hexists("data_source:hash:name_to_id", "jobs").should be_true
  end

  it "returns the id from values with #id_for_values if :get_by is true" do
    DataSource.attribute :domain
    two_fields = subject.new(DataSource, [:name, :domain], :get_by => true)
    two_fields.add("ze-id", ["jobs", "apple.com"])
    two_fields.id_for_values("jobs", "apple.com").should == "ze-id"
    one_field = subject.new(DataSource, :name, :get_by => true)
    one_field.add("ze-id", "jobs")
    one_field.id_for_values("jobs").should == "ze-id"
  end

  it "removes a string from the index with #rem" do
    @index.add("ze-id", "allo")
    @index.rem("ze-id", "allo")
    Souvenirs.driver.smembers("data_source:uidx:all_ids").should == []
  end

  it "returns the number of entries with #count" do
    5.times { |i| @index.add("ze-id", i.to_s) }
    @index.count.should == 5
  end

  it "returns all the strings from the index with #all" do
    %w(allo la terre).each { |v| @index.add("ze-id", v) }
    @index.all.should =~ ["allo", "la", "terre"]
  end

  it "returns if a string already exists with #include?" do
    %w(allo la terre).each { |v| @index.add("ze-id", v) }
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
