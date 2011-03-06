require "spec_helper"

describe Ricordami::Model do
  uses_constants('User')

  it "uses ActiveSupport::Concern for a simple module structure" do
    Ricordami::Model.should be_a_kind_of(ActiveSupport::Concern)
  end

  it "includes the modules listed with #model_can" do
    User.model_can :be_queried, :be_validated, :have_relationships
    user = User.new
    user.should be_a_kind_of(Ricordami::CanBeQueried)
    user.should be_a_kind_of(Ricordami::CanBeValidated)
    user.should be_a_kind_of(Ricordami::CanHaveRelationships)
  end

  describe "when being included" do
    it "adds model naming" do
      model_name = User.model_name
      model_name.should == "User"
      model_name.singular.should == "user"
      model_name.plural.should == "users"
    end

    it "adds to_model for use with Rails" do
      user = User.new
      user.to_model.should == user
    end

    it "has a simple to_s method" do
    end

    describe "#to_key" do
      before(:each) do
        @user = User.new
        def @user.id; "some_id" end
      end

      it "returns [id] if persisted" do
        def @user.persisted?; true end
        @user.to_key.should == [@user.id]
      end

      it "returns nil if not persisted" do
        def @user.persisted?; false end
        @user.to_key.should be_nil
      end
    end

    describe "#to_param" do
      before(:each) do
        @user = User.new
        def @user.persisted?; true end
      end

      it "returns key joined by - if to_key present" do
        def @user.to_key; ["some", "id", "here"] end
        @user.to_param.should == "some-id-here"
      end

      it "returns nil if to_key nil" do
        def @user.persisted?; false end
        @user.to_param.should be_nil
      end
    end
  end
end
