require "spec_helper"

describe Souvenirs::HasIndices do
  it "requires the module Souvenirs::HasIndices" do
    lambda {
      WillFail = Class.new do
        include Souvenirs::HasIndices
      end
    }.should raise_error(RuntimeError)
  end

  describe "the class" do
    uses_constants("Car")
    before(:each) do
      Car.attribute :model
      Car.attribute :name
    end

    describe "declaring a unique index" do
      it "can declare a unique index with #index" do
        index = Car.index :unique => :model
        Car.indices[:all_models].should be_a(Souvenirs::UniqueIndex)
        Car.indices[:all_models].should == index
      end

      it "raises an error if an index is not declared unique" do
        lambda { Car.index }.should raise_error(Souvenirs::InvalidIndexDefinition)
      end

      it "saves the values of the unique attributes into the indices" do
        Car.index :unique => :name
        car = Car.new(:name => "Prius")
        car.save
        Car.indices[:all_names].all.should == ["Prius"]
      end

      it "replaces old values with new ones into the indices" do
        Car.index :unique => :name
        car = Car.new(:name => "Prius")
        car.save
        Car.indices[:all_names].all.should == ["Prius"]
        car.name = "Rav4"
        car.save
        Car.indices[:all_names].all.should == ["Rav4"]
      end

      it "deletes the values of the unique attributes from the indices" do
        Car.index :unique => :name
        car = Car.create(:name => "Prius")
        car.delete.should be_true
        Car.indices[:all_names].all.should be_empty
      end

      it "adds a get_by_xxx method for each unique index xxx declared if :get_by is true" do
        Car.index :unique => :name, :get_by => true
        %w(il etait un petit navire).each { |n| Car.create!(:name => n) }
        Car.get_by_name("petit").name.should == "petit"
      end

      it "doesn't add the get_by_xxx method if :get_by is not true" do
        Car.index :unique => :name
        Car.should_not respond_to(:get_by_name)
      end
    end
  end
end
