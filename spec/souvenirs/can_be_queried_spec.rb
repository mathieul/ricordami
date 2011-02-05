require "spec_helper"

describe Souvenirs::CanBeQueried do
  uses_constants("Tenant")

  it "requires the module Souvenirs::CanBePersisted" do
    lambda {
      WillFail = Class.new do
        include Souvenirs::CanBeQueried
      end
    }.should raise_error(RuntimeError)
  end

  describe "#get & #get!" do
    it "loads a model with #get when it exists" do
      Tenant.attribute :language
      Tenant.new(:id => "Francois", :language => "French").save
      tenant = Tenant.get("Francois")
      tenant.id.should == "Francois"
      tenant.language.should == "French"
      tenant.should be_persisted
    end

    it "#get returns nil if the model can't be loaded" do
      Tenant.get("doesn't exist").should be_nil
    end

    it "#get! behaves just like #get when the model is found" do
      Tenant.attribute :language
      Tenant.new(:id => "Francois", :language => "French").save
      tenant = Tenant.get!("Francois")
      tenant.attributes.should == {
        "id" => "Francois",
        "language" => "French"
      }
      tenant.should be_persisted
    end

    it "#get! raises an error if the model is not found" do
      lambda {
        Tenant.get!("doesn't exist")
      }.should raise_error(Souvenirs::NotFound)
    end
  end
end
