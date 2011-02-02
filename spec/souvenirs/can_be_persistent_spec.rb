require "spec_helper"

describe Souvenirs::CanBePersistent do
  uses_constants("Tenant")

  it "is not persisted after it's just been initialized" do
    tenant = Tenant.new
    tenant.should_not be_persisted
  end

  it "is persisted after it's been successfully saved with #save" do
    tenant = Tenant.new
    tenant.save
    tenant.should be_persisted
  end

  it "saves the attribute values of a new model with #save" do
    Tenant.attribute :balance
    tenant = Tenant.new(:id => "jojo", :balance => "-$99.98")
    tenant.save
    attributes = Souvenirs.driver.hgetall("tenant:jojo:attributes")
    attributes["id"].should == "jojo"
    attributes["balance"].should == "-$99.98"
  end

  it "loads a model with #get when it exists" do
    Tenant.attribute :language
    Tenant.new(:id => "Francois", :language => "French").save
    tenant = Tenant.get("Francois")
    tenant.id.should == "Francois"
    tenant.language.should == "French"
  end

  it "#get returns nil if the model can't be loaded" do
    Tenant.get("doesn't exist").should be_nil
  end

  it "#get! behaves just like #get when the model is found" do
    Tenant.attribute :language
    Tenant.new(:id => "Francois", :language => "French").save
    Tenant.get!("Francois").attributes.should == {
      "id" => "Francois",
      "language" => "French"
    }
  end

  it "#get! raises an error if the model is not found" do
    lambda {
      Tenant.get!("doesn't exist")
    }.should raise_error(Souvenirs::NotFound)
  end
end
