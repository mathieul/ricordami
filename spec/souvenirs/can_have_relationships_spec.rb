require "spec_helper"
require "souvenirs/can_have_relationships"

describe Souvenirs::CanHaveRelationships do
  uses_constants("Computer", "Software")

  before(:each) do
    Computer.send(:include, Souvenirs::CanHaveRelationships)
    Computer.attribute :model
    Software.send(:include, Souvenirs::CanHaveRelationships)
    Software.attribute :name
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

  describe "instance that is referenced..." do
    before(:each) do
      Software.referenced_in :computer
    end

    it "creates an attribute for the referenced objects" do
      game = Software.create(:name => "Masquerade")
      game.computer_id.should be_nil
    end

    it "can access the referencer object with a method of the name of the reference" do
      game = Software.create(:name => "Masquerade")
      game.computer.should be_nil
      computer = Computer.create(:model => "IIc")
      game.computer_id = computer.id
      game.computer.should be_a(Computer)
      game.computer.model.should == "IIc"
    end

    describe "handling caching" do
      before(:each) do
        Computer.index :unique => :model, :get_by => true
        %w(IIc Macintosh).each { |model| Computer.create(:model => model).should be_true }
      end

      it "caches the referrer isntance after it was cached" do
        computer = Computer.get_by_model("IIc")
        game = Software.create(:name => "Masquerade", :computer_id => computer.id)
        game.computer.should == game.computer
      end

      it "updates the referrer when changing the referrer id" do
        game = Software.create(:name => "Sorcery")
        game.computer.should be_nil
        game.computer_id = Computer.get_by_model("IIc").id
        game.computer.model.should == "IIc"
        game.computer_id = Computer.get_by_model("Macintosh").id
        game.computer.model.should == "Macintosh"
        game.computer_id = nil
        game.computer.should be_nil
      end

      it "sweeps the referrer instance from the cache after it is reloaded" do
        game = Software.create(:name => "Swashbuckler",
                               :computer_id => Computer.get_by_model("IIc").id)
        game.computer.model.should == "IIc"
        game.update_attributes(:computer_id => Computer.get_by_model("Macintosh").id)
        game.computer.model.should == "Macintosh"
      end
    end
  end

  describe "instance that references many..." do
    it "can list all the objects it references with the reference method" do
      pending
      appleIIc = Computer.create(:model => "IIc")
    end
  end
end
