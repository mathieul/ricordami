require "spec_helper"

describe Ricordami::IsPersisted do
  uses_constants("Tenant")

  it "is not persisted and is a new record after it's just been initialized" do
    tenant = Tenant.new
    tenant.should_not be_persisted
    tenant.should be_a_new_record
  end

  it "is persisted and not a new record after it's been successfully saved with #save" do
    tenant = Tenant.new
    tenant.save
    tenant.should be_persisted
    tenant.should_not be_a_new_record
  end

  it "returns the redis driver instance with #redis" do
    Tenant.redis.should == Ricordami.driver
    Tenant.new.redis.should == Ricordami.driver
  end

  describe "#save & #create" do
    shared_examples_for "a persister" do
      it "persists a new model" do
        Tenant.attribute :balance
        persister_action.call
        attributes = Ricordami.driver.hgetall("Tenant:att:jojo")
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
  end

  describe "#reload and #update_attributes" do
    it "reloads the attribute values from the DB with #reload" do
      Tenant.attribute :name
      tenant = Tenant.create(:name => "gainsbourg")
      tenant.name = "updated"
      tenant.name.should == "updated"
      tenant.reload
      tenant.name.should == "gainsbourg"
    end

    it "updates passed attribute values and saves the model with #update_attributes" do
      [:first, :last].each { |a| Tenant.attribute a }
      tenant = Tenant.create(:first => "serge", :last => "gainsbourg")
      tenant.update_attributes(:first => "SERGE").should be_true
      tenant.reload
      tenant.first.should == "SERGE"
      tenant.last.should == "gainsbourg"
    end

    it "raise an error if #update_attributes can't save the changes" do
      tenant = Tenant.create(:id => "gainsbare")  # id is read-only
      lambda {
        tenant.update_attributes(:id => "gainsbourg")
      }.should raise_error(Ricordami::ReadOnlyAttribute)
    end
  end

  describe "grouping DB operations with #queue_saving_operations" do
    it "raises an error if no block is passed" do
      lambda {
        Tenant.queue_saving_operations
      }.should raise_error(ArgumentError)
    end

    it "raises an error if the block passed doesn't take 2 arguments" do
      lambda {
        Tenant.queue_saving_operations { |one| [one] }
      }.should raise_error(ArgumentError)
    end

    it "allows to queue DB operations that will run when instance is saved" do
      logs = []
      Tenant.attribute :name
      Tenant.queue_saving_operations do |obj, session|
        logs << if obj.persisted?
          "ALREADY persisted"
        else
          "NOT persisted"
        end
      end
      tenant = Tenant.new
      tenant.save
      tenant.update_attributes(:name => "blah")
      logs.should == ["NOT persisted", "ALREADY persisted"]
    end
  end

  describe "grouping DB operations with #queue_deleting_operations" do
    it "raises an error if no block is passed" do
      lambda {
        Tenant.queue_deleting_operations
      }.should raise_error(ArgumentError)
    end

    it "raises an error if the block passed doesn't take 2 arguments" do
      lambda {
        Tenant.queue_deleting_operations { |one| [one] }
      }.should raise_error(ArgumentError)
    end

    it "allows to queue DB operations that will run when instance is deleted" do
      logs = []
      Tenant.attribute :name
      Tenant.queue_deleting_operations { |obj, session| logs << "Tenant deleted #1" }
      Tenant.queue_deleting_operations { |obj, session| logs << "Tenant deleted #2" }
      tenant = Tenant.create
      tenant.delete
      logs.should == ["Tenant deleted #2", "Tenant deleted #1"]
    end
  end

  describe "#delete" do
    before(:each) { Tenant.attribute :name }
    let(:tenant) { Tenant.create(:id => "myid") }

    it "deletes the attributes from the DB" do
      tenant.delete.should be_true
      from_db = Ricordami.driver.hgetall("Tenant:att:myid")
      from_db.should be_empty
    end

    it "knows when a model has been deleted" do
      tenant.should_not be_deleted
      tenant.delete
      tenant.should be_deleted
    end

    it "freezes the model after deleting it" do
      tenant.delete
      tenant.should be_frozen
    end

    it "can't save a model that was deleted" do
      tenant.delete
      lambda { tenant.save }.should raise_error(Ricordami::ModelHasBeenDeleted)
    end

    it "can't update the attributes of a model that was deleted" do
      tenant.delete
      lambda {
        tenant.update_attributes(:name => "titi")
      }.should raise_error(Ricordami::ModelHasBeenDeleted)
    end

    it "can't delete a model that was deleted" do
    end
  end
end
