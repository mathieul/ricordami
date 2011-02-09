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
end
