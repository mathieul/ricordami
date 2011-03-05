# -*- encoding: utf-8 -*-
require "spec_helper"
require "ricordami/can_have_relationships"

describe Ricordami::CanHaveRelationships do
  uses_constants("Computer", "Software", "Editor")

  before(:each) do
    Computer.send(:include, Ricordami::CanHaveRelationships)
    Computer.attribute :model
    Computer.index :unique => :model, :get_by => true
    Computer.references_many :softwares
    Software.send(:include, Ricordami::CanHaveRelationships)
    Software.attribute :name
    Software.index :unique => :name, :get_by => true
    Software.referenced_in :computer
    Software.referenced_in :editor
    Editor.send(:include, Ricordami::CanHaveRelationships)
    Editor.attribute :corp_name
    Editor.index :unique => :corp_name, :get_by => true
    Editor.references_one :software
  end

  describe "class" do
    it "can declare a :referenced_in relationship with #referenced_in" do
      Software.referenced_in :computer
      Software.relationships[:computer].should be_a(Ricordami::Relationship)
      Software.relationships[:computer].type.should == :referenced_in
      Software.relationships[:computer].name.should == :computer
      Software.relationships[:computer].object_kind.should == :computer
    end

    it "can declare a :references_many relationship with #references_many" do
      Computer.references_many :softwares, :dependent => :nullify, :as => :softs
      Computer.relationships[:softs].should be_a(Ricordami::Relationship)
      Computer.relationships[:softs].type.should == :references_many
      Computer.relationships[:softs].name.should == :softs
      Computer.relationships[:softs].object_kind.should == :software
      Computer.relationships[:softs].dependent.should == :nullify
    end

    it "can declare a :references_one relationship with #references_one" do
      Editor.references_one :software, :dependent => :nullify
      Editor.relationships[:software].should be_a(Ricordami::Relationship)
      Editor.relationships[:software].type.should == :references_one
      Editor.relationships[:software].name.should == :software
      Editor.relationships[:software].object_kind.should == :software
      Editor.relationships[:software].dependent.should == :nullify
    end
  end

  describe "instance that is referenced..." do
    it "creates an attribute for the referrer id" do
      game = Software.create(:name => "Masquerade")
      game.computer_id.should be_nil
    end

    it "indexes the referrer id" do
      iic = Computer.create(:model => "IIc")
      mac = Computer.create(:model => "Macintosh")
      Software.create(:name => "Masquerade", :computer_id => iic.id)
      Software.create(:name => "Transylvania", :computer_id => iic.id)
      Software.create(:name => "Dungeon Master", :computer_id => mac.id)
      Software.where(:computer_id => iic.id).map(&:name).should =~ ["Masquerade", "Transylvania"]
    end

    it "can access the referrer with a method of the name of the reference" do
      game = Software.create(:name => "Masquerade")
      game.computer.should be_nil
      computer = Computer.create(:model => "IIc")
      game.computer_id = computer.id
      game.computer.should be_a(Computer)
      game.computer.model.should == "IIc"
    end

    describe "handling caching" do
      before(:each) do
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
    before(:each) do
      @iic = Computer.create(:model => "IIc")
      @mac = Computer.create(:model => "MacBook Air")
      [
        [@iic, "Masquerade"], [@iic, "Transylvania"], [@iic, "Bruce Lee"],
        [@iic, "Karateka"], [@mac, "Half-Life"], [@mac, "Chopper 2"]
      ].each do |computer, soft_name|
        Software.create(:name => soft_name, :computer_id => computer.id)
      end
    end

    it "has a method to access its referenced objects" do
      @iic.should respond_to(:softwares)
    end

    it "can list all the objects it references with the reference method" do
      @iic.softwares.map(&:name).should =~ ["Masquerade", "Transylvania",
                                            "Bruce Lee", "Karateka"]
      @mac.softwares.map(&:name).should =~ ["Half-Life", "Chopper 2"]
    end

    it "can return there is no reference objects when non persisted" do
      Computer.new.softwares.map(&:name).should == []
      Computer.new.softwares.should be_empty
      Computer.new.softwares.count.should == 0
    end

    it "can build a new reference object through the reference method" do
      soft = @mac.softwares.build
      soft.should_not be_persisted
      soft.computer_id.should == @mac.id
    end

    it "can create a new reference object through the reference method" do
      soft = @mac.softwares.create(:name => "Call of Duty 4")
      soft.should be_persisted
      soft.computer_id.should == @mac.id
      soft.name.should == "Call of Duty 4"
    end

    it "can have more than 1 reference for the same type of object" do
      Computer.references_many :softwares, :as => :softs, :alias => :host, :dependent => :delete
      Software.referenced_in :computer, :as => :host, :alias => :softs
      iie = Computer.create(:model => "IIe")
      iie.softs.create(:name => "Masquerade")
      iie.softwares.create(:name => "Conan")
      iie.softs.map(&:name).should == ["Masquerade"]
      iie.softwares.map(&:name).should == ["Conan"]
    end

    it "deletes dependents when delete is set to :dependent" do
      Computer.references_many :softwares, :as => :softs, :dependent => :delete
      iie = Computer.create(:model => "IIe")
      iie.softs.create(:name => "Castle Wolfenstein")
      Software.get_by_name("Castle Wolfenstein").should_not be_nil
      iie.delete
      lambda {
        Software.get_by_name("Castle Wolfenstein")
      }.should raise_error(Ricordami::NotFound)
    end

    it "sets to nil reference's referrer_id when delete is set to :nullify" do
      Computer.references_many :softwares, :as => :softs, :alias => :host, :dependent => :nullify
      Software.referenced_in :computer, :as => :host, :alias => :softs
      iie = Computer.create(:model => "IIe")
      iie.reload
      iie.softs.create(:name => "Castle Wolfenstein")
      Software.get_by_name("Castle Wolfenstein").host_id.should == iie.id
      iie.delete
      Software.get_by_name("Castle Wolfenstein").host_id.should be_empty
    end
  end

  describe "instance that references one..." do
    before(:each) do
      @aes = Editor.create(:corp_name => "American Eagle Software")
      Software.create(:name => "Masquerade", :editor_id => @aes.id)
      @datasoft = Editor.create(:corp_name => "Datasoft")
      Software.create(:name => "Bruce Lee", :editor_id => @datasoft.id)
    end

    it "has a method to access its referenced object" do
      @aes.should respond_to(:software)
    end

    it "can fetch the object it references with the reference method" do
      @aes.software.name.should == "Masquerade"
      @datasoft.software.name.should == "Bruce Lee"
    end

    it "can return there is no reference objects when non persisted" do
      Editor.new.software.should be_nil
    end

    it "can build a new reference object through a build reference method" do
      soft = @aes.build_software
      soft.should_not be_persisted
      soft.editor_id.should == @aes.id
    end

    it "can create a new reference object through the reference method" do
      soft = @datasoft.create_software(:name => "Alternate Reality: The City")
      soft.should be_persisted
      soft.editor_id.should == @datasoft.id
      soft.name.should == "Alternate Reality: The City"
    end

    it "can have more than 1 reference for the same type of object" do
      Editor.references_one :software, :as => :soft, :alias => :second_editor, :dependent => :delete
      Software.referenced_in :editor, :as => :second_editor, :alias => :soft
      broderbund = Editor.create(:corp_name => "Brøderbund")
      broderbund.create_software(:name => "Karateka")
      broderbund.create_soft(:name => "Lode Runner")
      broderbund.software.name.should == "Karateka"
      broderbund.soft.name.should == "Lode Runner"
    end

    it "deletes dependents when delete is set to :dependent" do
      Editor.references_one :software, :as => :soft, :dependent => :delete
      broderbund = Editor.create(:corp_name => "Brøderbund")
      broderbund.create_soft(:name => "Karateka")
      Software.get_by_name("Karateka").should_not be_nil
      broderbund.delete
      lambda {
        Software.get_by_name("Karateka")
      }.should raise_error(Ricordami::NotFound)
    end

    it "sets to nil reference's referrer_id when delete is set to :nullify" do
      Editor.references_one  :software, :as => :soft, :alias => :developper, :dependent => :nullify
      Software.referenced_in :editor, :as => :developper, :alias => :soft
      broderbund = Editor.create(:corp_name => "Brøderbund")
      broderbund.reload
      broderbund.create_soft(:name => "Choplifter")
      Software.get_by_name("Choplifter").developper_id.should == broderbund.id
      broderbund.delete
      Software.get_by_name("Choplifter").developper_id.should be_empty
    end
  end
end
