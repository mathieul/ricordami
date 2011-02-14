require "spec_helper"
require "souvenirs/query"

describe Souvenirs::Query do

  describe "instance" do
    uses_constants("Instrument")
    let(:query) { Souvenirs::Query.new(Instrument) }

    it "has expressions" do
      query.expressions.should == []
    end

    describe "#and" do
      it "saves :and expressions" do
        query.and(:allo => "la terre")
        query.expressions.pop.should == [:and, {:allo => "la terre"}]
      end

      it "uses :where as an alias for :and" do
        query.where(:allo => "la terre")
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

    describe "running the query" do
      it "delegates #all to the runner" do
        Instrument.should_receive(:all).with([[:and, {:key => "val"}]], nil)
        query.and(:key => "val").all
      end

      it "delegates #first to the runner" do
        Instrument.should_receive(:first).with([[:and, {:key => "val"}]], [:key, :asc])
        query.and(:key => "val").sort(:key).first
      end

      it "delegates #last to the runner" do
        Instrument.should_receive(:last).with([[:and, {:key => "val"}]], [:key, :desc])
        query.and(:key => "val").sort(:key, :desc).last
      end
    end

    describe "sorting the query" do
      it "remembers the sorting attribute with #sort" do
        query.sort(:username)
        query.sort_by.should == :username
      end

      it "remembers the sorting direction with #sort" do
        query.sort(:username)
        query.sort_dir.should == :asc
        query.sort(:username, :desc)
        query.sort_dir.should == :desc
      end

      it "raises an error if the sorting order is not :asc or :desc" do
        lambda {
          query.sort(:username, :blah)
        }.should raise_error(ArgumentError)
      end
    end
  end
end
