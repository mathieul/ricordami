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
    describe ":and" do
      before(:each) do
        Customer.index :simple => :country
        Customer.index :simple => :sex
        Customer.create(:name => "Zhanna", :sex => "F", :country => "Latvia")
        Customer.create(:name => "Mathieu", :sex => "M", :country => "France")
        Customer.create(:name => "Sophie", :sex => "F", :country => "USA")
        Customer.create(:name => "Brioche", :sex => "F", :country => "USA")
      end

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
        %w(Sophie Zhanna Mathieu).each { |n| Customer.create(:name => n) }
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
  end
end
