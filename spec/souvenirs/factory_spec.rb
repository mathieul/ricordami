require "spec_helper"

describe Souvenirs::Factory do
  subject { Souvenirs::Factory }

  describe "#id_generator" do
    it "returns a sequence generator for the model" do
      gen1 = subject.id_generator("User")
      10.times { |i| gen1.call.should == i + 1 }
      gen2 = subject.id_generator("Car")
      gen2.call.should == 1
      gen2.call.should == 2
    end
  end

  describe "#key_name" do
    it "returns a key name for a sequence with :sequence" do
      name = subject.key_name(:sequence, :type => "id", :model => "Boat")
      name.should == "Boat:seq:id"
    end

    it "returns a key name for model attributes with :attributes" do
      name = subject.key_name(:attributes, :model => "Boat", :id => "42")
      name.should == "Boat:att:42"
    end

    it "returns a key name for a unique index with :unique_index" do
      name = subject.key_name(:unique_index, :model => "Call", :name => "ani")
      name.should == "Call:udx:ani"
    end

    it "returns a key name for a hash reference with :hash_ref" do
      name = subject.key_name(:hash_ref, :model => "Call", :fields=> ["ani", "dnis"])
      name.should == "Call:hsh:ani_dnis_to_id"
    end
  end
end
