require "spec_helper"

describe Ricordami::HasIndices do
  describe "the class" do
    uses_constants("Car")
    before(:each) do
      Car.attribute :model
      Car.attribute :name
    end

    it "raises an error when declaring an index that's neither unique or a value index" do
      lambda { Car.index }.should raise_error(Ricordami::InvalidIndexDefinition)
    end

    describe "declaring a value index" do
      it "can declare a value index with #index" do
        index = Car.index :value => :model
        Car.indices[:v_model].should be_a(Ricordami::ValueIndex)
        Car.indices[:v_model].should == index
      end
    end

    describe "declaring a unique index" do
      it "can declare a unique index with #index" do
        index = Car.index :unique => :model
        Car.indices[:u_model].should be_a(Ricordami::UniqueIndex)
        Car.indices[:u_model].should == index
      end

      it "can give a scope to a unique index with :scope option" do
        Car.attribute :brand
        index = Car.index :unique => :model, :scope => :brand
        Car.indices[:u_model].scope.should == [:brand]
        Car.indices[:u_model].fields.should == [:model, :brand]
      end

      it "discards the subsequent declarations if the same index is created more than once" do
        Car.index :unique => :model, :get_by => true
        Car.indices[:u_model].need_get_by.should be_true
        Car.index :unique => :model, :get_by => false
        Car.indices[:u_model].need_get_by.should be_true
      end

      it "saves the values of the unique attributes into the indices" do
        Car.index :unique => :name
        car = Car.new(:name => "Prius")
        car.save
        Car.indices[:u_name].all.should == ["Prius"]
      end

      it "replaces old values with new ones into the indices" do
        Car.index :unique => :name
        car = Car.new(:name => "Prius")
        car.save
        Car.indices[:u_name].all.should == ["Prius"]
        car.name = "Rav4"
        car.save
        Car.indices[:u_name].all.should == ["Rav4"]
      end

      it "deletes the values of the unique attributes from the indices" do
        Car.index :unique => :name
        car = Car.create(:name => "Prius")
        car.delete.should be_true
        Car.indices[:u_name].all.should be_empty
      end

      it "adds a get_by_xxx method for each unique index xxx declared if :get_by is true" do
        Car.index :unique => :name, :get_by => true
        %w(il etait un petit navire).each { |n| Car.create(:name => n) }
        Car.get_by_name("petit").name.should == "petit"
      end

      it "doesn't add the get_by_xxx method if :get_by is not true" do
        Car.index :unique => :name
        Car.should_not respond_to(:get_by_name)
      end
    end
  end
end
