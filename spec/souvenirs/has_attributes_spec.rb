require "spec_helper"

describe Souvenirs::HasAttributes do
  describe "the class" do
    uses_constants("Boat")

    it "can declare attributes using #attribute" do
      Boat.attribute :sail
      Boat.attributes[:sail].should be_a(Souvenirs::Attribute)
      Boat.attributes[:sail].name.should == "sail"
    end

    it "can pass attribute options when declaring an attribute" do
      Boat.attribute :color, :default => "black", :read_only => true
      Boat.attributes[:color].default_value.should == "black"
      Boat.attributes[:color].should be_read_only
    end
  end

  describe "an instance" do
    uses_constants("User")

    it "can be initialized with a hash of attribute values" do
      User.attribute :name
      User.attribute :age
      User.attribute :ssn
      user = User.new(:name => "jean", :age => "20", :ssn => "1234567890")
      user.name.should == "jean"
      user.age.should == "20"
      user.ssn.should == "1234567890"
    end

    it "can set attributes using writers" do
      User.attribute :email
      user = User.new
      user.email.should be_nil
      user.email = "blah@toto.com"
      user.email.should == "blah@toto.com"
    end

    it "sets default values when initializing without argument" do
      User.attribute :age, :default => "18"
      User.new.age.should == "18"
    end

    it "overwrites default values with arguments when initializing" do
      User.attribute :age, :default => "18"
      User.new(:age => "12").age.should == "12"
    end

    it "can't change a read-only attribute that was initialized" do
      User.attribute :name
      User.attribute :ssn, :read_only => true
      user = User.new(:name => "James Bond", :ssn => "007")
      lambda {
        user.ssn = "1234567890"
      }.should raise_error(Souvenirs::ReadOnlyAttribute)
      lambda {
        user.name = "Titi"
      }.should_not raise_error(Souvenirs::ReadOnlyAttribute)
    end

    it "can set a read-only attribute only once if it was not initialized" do
      User.attribute :name
      User.attribute :ssn, :read_only => true
      user = User.new
      lambda {
        user.ssn = "1234567890"
        user.name = "Titi"
        user.name = "Bob Loblaw"
      }.should_not raise_error(Souvenirs::ReadOnlyAttribute)
      lambda {
        user.ssn = "0987654321"
      }.should raise_error(Souvenirs::ReadOnlyAttribute)
    end

    it "has an 'id' attribute set by default to a sequence if not overriden when saved" do
      user = User.create
      user.id.should be_present
      user.id.should == 1
    end

    it "overides the value of its 'id' attribute when a value is passed" do
      user = User.create(:id => "foo")
      user.id.should == "foo"
    end

    it "defines 'id' as a read_only attribute" do
      user = User.create
      lambda {
        user.id = "try me"
      }.should raise_error(Souvenirs::ReadOnlyAttribute)
    end

    it "returns the name of the attributes key with #attributes_key_name" do
      user = User.new(:id => "ze_id")
      user.instance_eval { attributes_key_name }.should == "user:ze_id:attributes"
    end

    it "updates the attribute values in memory with #update_mem_attributes!" do
      User.attribute :age
      User.attribute :sex
      user = User.new(:age => "12", :sex => "male")
      user.update_mem_attributes!(:age => "18", :sex => "female")
      user.age.should == "18"
      user.sex.should == "female"
    end

    it "can't change read-only attributes with #update_mem_attributes!" do
      User.attribute :name
      User.attribute :ssn, :read_only => true
      user = User.new(:name => "James Bond", :ssn => "007")
      lambda {
        user.update_mem_attributes!(:ssn => "1234567890")
      }.should raise_error(Souvenirs::ReadOnlyAttribute)
    end

    it "updates the attribute values in memory with #load_mem_attributes" do
      User.attribute :age
      user = User.new(:age => "12")
      user.load_mem_attributes(:age => "18")
      user.age.should == "18"
    end

    it "changes read-only attributes with #load_mem_attributes" do
      User.attribute :ssn, :read_only => true
      user = User.new(:ssn => "007")
      lambda {
        user.load_mem_attributes(:ssn => "1234567890")
      }.should_not raise_error
    end

    it "can't change the attributes of a model that was deleted" do
      User.attribute :age
      user = User.create(:age => "42")
      user.delete
      lambda { user.age = "12" }.should raise_error(Souvenirs::ModelHasBeenDeleted)
    end
  end

  describe "keeps track of dirty attributes" do
    uses_constants("Plane")
    before(:each) do
      Plane.attribute :brand
      Plane.attribute :model
    end

    describe "a new record" do
      before(:each) { @plane = Plane.new }
      let(:plane) { @plane }

      it "was not changed if it doesn't have attributes" do
        plane.should_not be_changed
        plane.changed.should be_empty
        plane.changes.should be_empty
      end

      it "was changed when initialized with attributes" do
        plane = Plane.new(:brand => "Airbus", :model => "320")
        plane.should be_changed
        plane.changed.should =~ ["brand", "model"]
        plane.changes.should == {"brand" => [nil, "Airbus"], "model" => [nil, "320"]}
      end

      it "knows when an attribute value changes" do
        plane.brand = "Boeing"
        plane.should be_changed
        plane.changed.should == ["brand"]
        plane.changes["brand"].should == [nil, "Boeing"]
      end

      it "knows when an attribute value actually didn't change" do
        plane.brand = nil
        plane.should_not be_changed
      end

      it "was not changed after it was saved" do
        plane.model = "380"
        plane.save
        plane.should_not be_changed
      end

      it "knows when it was changed before being saved" do
        plane.model = "380"
        plane.save
        plane.previous_changes["model"].should == [nil, "380"]
      end
    end

    describe "a persisted record" do
      before(:each) { Plane.create(:id => "A320", :brand => "Airbus", :model => "320") }
      let(:plane) { Plane["A320"] }

      it "was not changed when it's just loaded from the DB" do
        plane.should_not be_changed
      end

      it "was not changed after reloading it with #reload" do
        plane.brand = "Toys'R US"
        plane.reload
        plane.should_not be_changed
      end

      it "knows when an attribute value actually didn't change" do
        plane.brand = "Airbus"
        plane.should_not be_changed
        plane.brand = "Boeing"
        plane.brand = "Airbus"
        plane.should_not be_changed
      end

      it "knows which attributes changed when running #update_attributes" do
        plane.brand = "Boeing"
        plane.update_attributes(:brand => "Airbus", :model => "380")
        plane.should_not be_changed
        plane.previous_changes.should == {"model" => ["320", "380"]}
      end
    end
  end
end
