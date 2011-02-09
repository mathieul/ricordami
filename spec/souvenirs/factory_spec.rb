require "spec_helper"

describe Souvenirs::Factory do
  subject { Souvenirs::Factory }

  describe "#id_generator" do
    it "raises an error if the id generator type is not supported" do
      lambda {
        subject.id_generator(:not_supported)
      }.should raise_error(Souvenirs::TypeNotSupported)
    end

    it "returns a UUID generator when passed :uuid" do
      generator = subject.id_generator(:uuid)
      uuid1, uuid2 = [generator.call, generator.call]
      uuid1.should_not == uuid2
      uuid1.should match(/[0-9a-f\-]/)
      uuid2.should match(/[0-9a-f\-]/)
    end

    it "returns a sequence generator when passed :sequence" do
      generator = subject.id_generator(:sequence)
      10.times do |i|
        generator.call.should == i + 1
      end
    end
  end

  describe "#key_name" do
    it "returns a key name for a sequence with :sequence" do
      name = subject.key_name(:sequence, :name => "id_generator")
      name.should == "global:seq:id_generator"
    end

    it "returns a key name for model attributes with :attributes" do
      name = subject.key_name(:attributes, :model => "boat", :id => "42")
      name.should == "boat:attributes:42"
    end

    it "returns a key name for a unique index with :unique_index" do
      name = subject.key_name(:unique_index, :model => "call", :name => "ani")
      name.should == "call:uidx:ani"
    end
  end
end
