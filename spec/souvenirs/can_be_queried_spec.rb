require "spec_helper"
require "souvenirs/can_be_queried"

describe Souvenirs::CanBeQueried do
  uses_constants("Customer")

  before(:each) do
    class Customer
      include Souvenirs::CanBeQueried
      attribute :country
      attribute :sex
      attribute :name
      attribute :kind
      attribute :no_index
    end
  end

  describe "building queries" do
    describe "#and" do
      it "returns a new query" do
        query = Customer.and
        query.should be_a(Souvenirs::Query)
      end

      it "passes self as the query runner to the query" do
        query = Customer.and
        query.runner.should == Customer
      end

      it "delegates #and to the new query" do
        query = Customer.and(:key => "value")
        query.expressions.should == [[:and, {:key => "value"}]]
      end
    end

    describe "#not" do
      it "returns a new query" do
        query = Customer.not
        query.should be_a(Souvenirs::Query)
      end

      it "delegates #not to the new query" do
        query = Customer.not(:key => "value")
        query.expressions.should == [[:not, {:key => "value"}]]
      end
    end

    describe "#any" do
      it "returns a new query" do
        query = Customer.any
        query.should be_a(Souvenirs::Query)
      end

      it "delegates #any to the new query" do
        query = Customer.any(:key => "value")
        query.expressions.should == [[:any, {:key => "value"}]]
      end
    end
  end

  describe "running queries" do
    before(:each) do
      Customer.index :simple => :country
      Customer.index :simple => :sex
      Customer.index :simple => :name
      Customer.index :simple => :kind
      Customer.create(:name => "Zhanna", :sex => "F", :country => "Latvia", :kind => "human")
      Customer.create(:name => "Mathieu", :sex => "M", :country => "France", :kind => "human")
      Customer.create(:name => "Sophie", :sex => "F", :country => "USA", :kind => "human")
      Customer.create(:name => "Brioche", :sex => "F", :country => "USA", :kind => "dog")
    end

    describe ":and" do
      it "raises an error if there's no simple index for one of the conditions" do
        lambda {
          Customer.and(:no_index => "Blah").all
        }.should raise_error(Souvenirs::MissingIndex)
      end

      it "returns an empty array if no conditions where passed" do
        Customer.and.all.should == []
      end

      it "returns the models found with #all (1 condition, 1 result)" do
        Customer.index :simple => :name
        found = Customer.and(:name => "Zhanna").all
        found.map(&:name).should == ["Zhanna"]
      end

      it "returns the models found with #all (2 conditions, 2 results)" do
        found = Customer.and(:country => "USA", :sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
      end

      it "returns the models found with #all for a composed query" do
        found = Customer.and(:country => "USA").and(:sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
      end
    end

    describe ":any" do
      it "raises an error if there's no simple index for one of the conditions" do
        lambda {
          Customer.any(:no_index => "Blah").all
        }.should raise_error(Souvenirs::MissingIndex)
      end

      it "returns an empty array if no conditions where passed" do
        Customer.any.all.should == []
      end

      it "returns the models found with #all (1 condition, 1 result)" do
        Customer.index :simple => :name
        found = Customer.any(:name => "Zhanna").all
        found.map(&:name).should == ["Zhanna"]
      end

      it "returns the models found with #all (2 conditions, 3 results)" do
        found = Customer.any(:country => "USA", :sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche", "Zhanna"]
      end

      it "returns the models found with #all for a composed query" do
        found = Customer.and(:country => "USA").any(:name => "Sophie", :kind => "dog").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
        found = Customer.and(:country => "USA").any(:name => "Sophie", :kind => "human").all
        found.map(&:name).should == ["Sophie"]
      end
    end
  end
end
