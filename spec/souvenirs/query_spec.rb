require "spec_helper"
require "souvenirs/query"

describe Souvenirs::Query do

  describe "instance" do
    let(:query) { Souvenirs::Query.new }

    it "has expressions" do
      query.expressions.should == []
    end

    describe "#and" do
      it "saves :and expressions" do
        query.and(:allo => "la terre")
        query.expressions.pop.should == [:and, {:allo => "la terre"}]
      end

      it "returns self" do
        query.and.should == query
      end
    end

    describe "#not" do
      it "saves :not expressions" do
        query.not(:allo => "la terre")
        query.expressions.pop.should == [:not, {:allo => "la terre"}]
      end

      it "returns self" do
        query.not.should == query
      end
    end

    describe "#any" do
      it "saves :any expressions" do
        query.any(:allo => "la terre")
        query.expressions.pop.should == [:any, {:allo => "la terre"}]
      end

      it "returns self" do
        query.any.should == query
      end
    end

  end
end
