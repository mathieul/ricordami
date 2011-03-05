require "spec_helper"

describe Ricordami::IsRetrievable do
  uses_constants("Tenant")

  describe "#get & #[]" do
    it "loads a model with #get when it exists" do
      Tenant.attribute :language
      Tenant.new(:id => "Francois", :language => "French").save
      tenant = Tenant.get("Francois")
      tenant.attributes.should == {
        "id" => "Francois",
        "language" => "French"
      }
      tenant.should be_persisted
    end

    it "#get raises an error if the model is not found" do
      lambda {
        Tenant.get("doesn't exist")
      }.should raise_error(Ricordami::NotFound)
    end

    it "#[] is an alias for get" do
      Tenant.new(:id => "myid").save
      Tenant["myid"].attributes["id"].should == "myid"
      lambda { Tenant["nope"] }.should raise_error(Ricordami::NotFound)
    end
  end

  describe "#all & #count" do
    it "saves the ids of new instances when saved" do
      Tenant.attribute :name
      instance = Tenant.new(:id => "hi")
      instance.save
      Tenant.indices[:id].all.should == ["hi"]
      instance.name = "john"
      instance.save
      Tenant.indices[:id].all.should == ["hi"]
    end

    it "returns all the instances with #all" do
      %w(allo la terre).each { |n| Tenant.create(:id => n) }
      Tenant.all.map(&:id).should =~ ["allo", "la", "terre"]
    end

    it "returns the number of instances with #count" do
      Tenant.count.should == 0
      Tenant.create(:id => "blah")
      Tenant.count.should == 1
      %w(allo la terre).each { |n| Tenant.create(:id => n) }
      Tenant.count.should == 4
    end
  end
end
