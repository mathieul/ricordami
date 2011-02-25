require "spec_helper"
require "souvenirs/can_have_relationships"

describe Souvenirs::CanHaveRelationships do
  uses_constants("Computer", "Software")

  before(:each) do
    Computer.send(:include, Souvenirs::CanHaveRelationships)
    Software.send(:include, Souvenirs::CanHaveRelationships)
  end

  describe "class" do
    it "can declare a :references_many relationship with #references_many" do
      Computer.references_many :softwares, :dependent => :nullify
      Computer.relationships[:softwares].should be_a(Souvenirs::Relationship)
      Computer.relationships[:softwares].type.should == :references_many
      Computer.relationships[:softwares].name.should == :softwares
      Computer.relationships[:softwares].dependent.should == :nullify
    end

    it "can declare a :referenced_in relationship with #referenced_in" do
      Software.referenced_in :computer
      Software.relationships[:computer].should be_a(Souvenirs::Relationship)
      Software.relationships[:computer].type.should == :referenced_in
      Software.relationships[:computer].name.should == :computer
    end
  end
end
