require "spec_helper"
require "souvenirs/can_be_validated"

describe Souvenirs::CanBeValidated do
  describe "Active Model validations" do
    uses_constants("Call")

    before(:each) do
      Call.class_eval do
        include Souvenirs::CanBeValidated
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

    it "can't validate a model that was deleted" do
      call = Call.create(:ani => "123", :dnis => "456")
      call.delete
      lambda { call.valid? }.should raise_error(Souvenirs::ModelHasBeenDeleted)
    end
  end

  describe "#save" do
    uses_constants("Post")

    before(:each) do
      Post.class_eval do
        include Souvenirs::CanBeValidated
        attribute :title
        validates_presence_of :title
      end
    end

    it "can't #save if it is not valid" do
      post = Post.new
      post.save.should be_false
    end

    it "can save if it is not valid but passed :validate => false" do
      Post.new.save(:validate => false).should be_true
    end
  end

  describe "validate attribute uniqueness" do
    uses_constants("User")

    before(:each) do
      User.class_eval do
        include Souvenirs::CanBeValidated
        attribute :username, :read_only => true
        attribute :wife
        validates_uniqueness_of :username
      end
    end

    it "is valid if no other instance uses the same attribute value" do
      user = User.new(:username => "Serge Gainsbourg")
      user.should be_valid
    end

    it "is not valid if another instance uses the same attribute value" do
      serge = User.new(:username => "Gainsbourg")
      serge.save.should be_true
      serge.should be_valid

      usurpateur = User.new(:username => "Gainsbourg")
      usurpateur.should_not be_valid
      usurpateur.should have(1).error
      usurpateur.errors[:username].should == ["is already used"]
    end

    it "allows to validate the uniqueness of an attribute that can be changed" do
      User.validates_uniqueness_of(:wife)
      User.create(:id => "serge", :username => "Gainsbourg", :wife => "Rita")
      serge = User["serge"]
      serge.should be_valid
      serge.save

      fred = User.new(:username => "Chichin", :wife => "Rita")
      fred.should_not be_valid
      fred.should have(1).error
      fred.errors[:wife].should == ["is already used"]
    end
  end
end
