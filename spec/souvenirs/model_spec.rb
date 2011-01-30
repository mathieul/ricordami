require "spec_helper"

describe Souvenirs::Model do
  uses_constants('Friend')

  it "uses ActiveSupport::Concern for a simple module structure" do
    Souvenirs::Model.should be_a_kind_of(ActiveSupport::Concern)
  end

  it "adds model naming" do
    model_name = Friend.model_name
    model_name.should == "Friend"
    model_name.singular.should == "friend"
    model_name.plural.should == "friends"
  end
end
