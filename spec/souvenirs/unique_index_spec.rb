require "spec_helper"

describe Souvenirs::UniqueIndex do
  subject { Souvenirs::UniqueIndex }

  before(:each) do
    create_constant("DataSource")
    DataSource.attribute :name
    @index = subject.new(DataSource, :id)
  end

  it "is initialized with a model, a name and the fields to be unique" do
    @index.model.should == DataSource
    @index.fields.should == [:id]
    @index.name.should == :id
  end

  it "returns its internal index name with #uidx_key_name" do
    @index.uidx_key_name.should == "DataSource:udx:id"
  end

  it "returns its internal reference name with #ref_key_name" do
    @index.ref_key_name.should == "DataSource:hsh:id_to_id"
  end

  it "adds a string to the index with #add" do
    @index.add("ze-id", "allo")
    Souvenirs.driver.smembers("DataSource:udx:id").should == ["allo"]
  end

  it "also indices the hash index with #add if fields is not :id and :get_by is true" do
    DataSource.attribute :domain
    other = subject.new(DataSource, [:name, :domain], :get_by => true)
    other.add("ze-id", ["jobs", "apple.com"])
    Souvenirs.driver.smembers("DataSource:udx:name_domain").should == ["jobs_-::-_apple.com"]
    Souvenirs.driver.hget("DataSource:hsh:name_domain_to_id", "jobs_-::-_apple.com").should == "ze-id"
  end

  it "doesn't index the has index with #add if :get_by is false or fields is :id" do
    one = subject.new(DataSource, :name)
    one.add("ze-id", "jobs")
    Souvenirs.driver.hexists("DataSource:hsh:name_to_id", "jobs").should be_false
    two = subject.new(DataSource, :id, :get_by => true)
    two.add("ze-id", "ze-id")
    Souvenirs.driver.hexists("DataSource:hsh:id_to_id", "ze-id").should be_false
    three = subject.new(DataSource, :name, :get_by => true)
    three.add("ze-id", "jobs")
    Souvenirs.driver.hexists("DataSource:hsh:name_to_id", "jobs").should be_true
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
    Souvenirs.driver.smembers("DataSource:udx:id").should == []
  end

  it "returns the redis command(s) to remove the value from the index when return_command is true" do
    command = @index.rem("ze-id", "allo", true)
    command.should == [[:srem, ["DataSource:udx:id", "allo"]]]
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
end
