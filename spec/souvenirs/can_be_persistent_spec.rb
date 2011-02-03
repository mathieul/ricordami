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

  describe "#save, #save!, #create & #create!" do
    shared_examples_for "a persister" do
      it "persists a new model" do
        Tenant.attribute :balance
        persister_action.call
        attributes = Souvenirs.driver.hgetall("tenant:jojo:attributes")
        attributes["id"].should == "jojo"
        attributes["balance"].should == "-$99.98"
      end
    end

    describe "#save" do
      let(:persister_action) {
        Proc.new {
          tenant = Tenant.new(:id => "jojo", :balance => "-$99.98")
          tenant.save.should be_true
        }
      }
      it_should_behave_like "a persister"
      it "returns false if saving failed" do
        switch_db_to_error
        Tenant.new.save.should be_false
        switch_db_to_ok
      end
    end

    describe "#save!" do
      let(:persister_action) {
        Proc.new {
          tenant = Tenant.new(:id => "jojo", :balance => "-$99.98")
          tenant.save!.should be_true
        }
      }
      it_should_behave_like "a persister"
      it "raises an error if saving failed" do
        switch_db_to_error
        lambda { Tenant.new.save! }.should raise_error(Souvenirs::WriteToDbFailed)
        switch_db_to_ok
      end
    end

    describe "#create" do
      let(:persister_action) {
        Proc.new {
          tenant = Tenant.create(:id => "jojo", :balance => "-$99.98")
          tenant.should be_a(Tenant)
          tenant.should be_persisted
        }
      }
      it_should_behave_like "a persister"
      it "returns an instance not persisted if creating failed" do
        switch_db_to_error
        tenant = Tenant.create(:id => "jojo", :balance => "-$99.98")
        tenant.should be_a(Tenant)
        tenant.should_not be_persisted
        switch_db_to_ok
      end
    end

    describe "#create!" do
      let(:persister_action) {
        Proc.new {
          tenant = Tenant.create!(:id => "jojo", :balance => "-$99.98")
          tenant.should be_a(Tenant)
          tenant.should be_persisted
        }
      }
      it_should_behave_like "a persister"
      it "raises an error if creating failed" do
        switch_db_to_error
        lambda {
          Tenant.create!(:id => "jojo", :balance => "-$99.98")
        }.should raise_error(Souvenirs::WriteToDbFailed)
        switch_db_to_ok
      end
    end
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
