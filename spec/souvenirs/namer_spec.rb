require "spec_helper"

describe Souvenirs::Namer do
  subject { Souvenirs::Namer }
  uses_constants("Call", "Leg", "Boat")

  describe "#key" do
    it "returns a key name for a sequence with :sequence" do
      name = subject.key(:sequence, :type => "id", :model => Boat)
      name.should == "Boat:seq:id"
    end

    it "returns a key name for model attributes with :attributes" do
      name = subject.key(:attributes, :model => Boat, :id => "42")
      name.should == "Boat:att:42"
    end

    it "returns a key name for a unique index with :unique_index" do
      name = subject.key(:unique_index, :model => Call, :name => "ani")
      name.should == "Call:udx:ani"
    end

    it "returns a key name for a hash reference with :hash_ref" do
      name = subject.key(:hash_ref, :model => Call, :fields=> ["ani", "dnis"])
      name.should == "Call:hsh:ani_dnis_to_id"
    end

    it "returns a key name for the value of a field of a model with :index" do
      name = subject.key(:index, :model => Leg, :field => :direction, :value => "inout")
      name.should == "Leg:idx:direction:aW5vdXQ="
    end

    it "returns a volatile key name for a set with :volatile_set" do
      kn1 = subject.key(:volatile_set, :model => Call,
                             :key => nil, :info => [:and, "username", "sex"])
      kn1.should == "~:Call:set:and(username,sex)"
      kn2 = subject.key(:volatile_set, :model => Call,
                             :key => "~:Call:set:and(username,sex)",
                             :info => [:or, "country"])
      kn2.should == "~:Call:set:and(username,sex):or(country)"
    end

    it "returns a temporary key name for a model with :model_tmp" do
      5.times do |i|
        name = subject.key(:model_tmp, :model => Leg)
        name.should == "Leg:val:_tmp:#{i + 1}"
      end
    end

    it "returns a key name for the model lock with :model_lock" do
      name = subject.key(:model_lock, :model => Leg, :id => 3)
      name.should == "Leg:val:3:_lock"
    end

    it "returns a key name for sort an attribute with :model_sort" do
      name = subject.key(:model_sort, :model => "Student", :sort_by => :name)
      name.should == "Student:att:*->name"
    end
  end
end
