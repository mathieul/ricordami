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
    end
  end

  describe "#and" do
    it "returns a new query" do
      query = Customer.and
      query.should be_a(Souvenirs::Query)
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
