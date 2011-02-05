require "spec_helper"

describe Souvenirs::CanBeValidated do

  describe "Active Model validations" do
    uses_constants("Call")

    before(:each) do
      Call.class_eval do
        attribute :ani
        attribute :dnis
        validates_presence_of :ani
        validates_numericality_of :dnis, :allow_blank => true, :message => "is not numeric"
        validate :cant_call_iself

        private
        def cant_call_iself
          return true if ani.blank?
          errors.add(:ani, "can't be the same as dnis") if ani == dnis
        end
      end
    end

    it "can validate the presence of an attribute value" do
      call = Call.new
      call.should_not be_valid
      call.should have(1).errors
      call.errors[:ani].should == ["can't be blank"]
    end

    it "can validate that a field is numeric" do
      call = Call.new(:ani => "123", :dnis => "nope")
      call.should_not be_valid
      call.should have(1).errors
      call.errors[:dnis].should == ["is not numeric"]
    end

    it "can do custom validation" do
      call = Call.new(:ani => "123", :dnis => "123")
      call.should_not be_valid
      call.should have(1).errors
      call.errors[:ani].should == ["can't be the same as dnis"]
    end
  end

end
