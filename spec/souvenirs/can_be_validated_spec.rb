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

  describe "#save" do
    uses_constants("Post")

    before(:each) do
      Post.class_eval do
        attribute :title
        validates_presence_of :title
      end
    end

    it "can't #save if it is not valid" do
      post = Post.new
      post.save.should be_false
    end

    it "it raises an error when #save! if it is not valid" do
      post = Post.new
      lambda { post.save! }.should raise_error(Souvenirs::ModelInvalid)
    end

    it "can save if it is not valid but passed :validate => false" do
      Post.new.save(:validate => false).should be_true
      lambda {
        Post.new.save!(:validate => false)
      }.should_not raise_error
    end
  end

  describe "validate attribute uniqueness" do
    uses_constants("User")

    before(:each) do
      User.class_eval do
        attribute :username
        validates_uniqueness_of :username
      end
    end

    it "is valid if no other instance uses the same attribute value" do
      user = User.new(:username => "Serge Gainsbourg")
      user.should be_valid
    end

    it "is not valid if another instance uses the same attribute value" do
      serge = User.new(:username => "Gainsbourg")
      serge.should be_valid

      usurpateur = User.new(:username => "Gainsbourg")
      usurpateur.should_not be_valid
      usurpateur.should have(1).error
      usurpateur.errors[:username].should == ["is already used"]
    end
  end
end
