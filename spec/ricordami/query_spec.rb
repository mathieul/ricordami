require "spec_helper"
require "ricordami/query"

describe Ricordami::Query do
  uses_constants("Instrument")
  let(:query) { Ricordami::Query.new(Instrument) }
  let(:cond) { Ricordami::Condition }

  it "has filters" do
    query.filters.should == []
  end

  describe "#and" do
    it "saves :and filters" do
      query.and(:allo => "la terre")
      query.filters.pop.should == [:and, [cond.new(:allo, :eq, "la terre")]]
    end

    it "uses :where as an alias for :and" do
      query.where(:allo => "la terre")
      query.filters.pop.should == [:and, [cond.new(:allo, :eq, "la terre")]]
    end

    it "returns self" do
      query.and.should == query
    end
  end

  describe "#not" do
    it "saves :not filters" do
      query.not(:allo => "la terre")
      query.filters.pop.should == [:not, [cond.new(:allo, :eq, "la terre")]]
    end

    it "returns self" do
      query.not.should == query
    end
  end

  describe "#any" do
    it "saves :any filters" do
      query.any(:allo => "la terre")
      query.filters.pop.should == [:any, [cond.new(:allo, :eq, "la terre")]]
    end

    it "returns self" do
      query.any.should == query
    end
  end

  describe "running the query" do
    it "delegates #all to the runner" do
      Instrument.should_receive(:all).with(:filters => [[:and, [cond.new(:key, :eq, "val")]]],
                                           :return => Instrument, :store => false)
      query.and(:key => "val").all
    end

    it "delegates #paginate to the runner" do
      Instrument.should_receive(:paginate).with(:filters => [[:and, [cond.new(:key, :eq, "val")]]],
                                                :page => 3,
                                                :per_page => 18,
                                                :return => Instrument, :store => false)
      query.and(:key => "val").paginate(:page => 3, :per_page => 18)
    end

    it "delegates #first to the runner" do
      Instrument.should_receive(:first).with(:filters => [[:and, [cond.new(:key, :eq, "val")]]],
                                             :sort_by => :key,
                                             :order => "ALPHA ASC",
                                             :return => Instrument,
                                             :store => false)
      query.and(:key => "val").sort(:key => :asc).first
    end

    it "delegates #last to the runner" do
      Instrument.should_receive(:last).with(:filters => [[:and, [cond.new(:key, :eq, "val")]]],
                                            :sort_by => :key,
                                            :order => "ALPHA DESC",
                                            :return => Instrument,
                                            :store => false)
      query.and(:key => "val").sort(:key => :desc).last
    end

    it "delegates #rand to the runner" do
      Instrument.should_receive(:respond_to?).with(:rand).and_return(true)
      Instrument.should_receive(:rand).with(:filters => [[:and, [cond.new(:key, :eq, "val")]]],
                                            :sort_by => :key,
                                            :order => "ALPHA ASC",
                                            :return => Instrument,
                                            :store => false)
      query.and(:key => "val").sort(:key => :asc).rand
    end

    it "returns the runner if it can't delegate to the runner" do
      Ricordami::Query.new([]).all.should == []
      Ricordami::Query.new([]).paginate.should == []
    end

    it "accepts any unknown method and delegate it to the result of #all" do
      instruments = %w(guitar bass drums).map { |value| Struct.new(:name).new(value) }
      Instrument.should_receive(:all).
        with(:filters => [[:and, [cond.new(:key, :eq, "val")]]],
             :return => Instrument,
             :store => false).
        and_return(instruments)
      query.and(:key => "val").map(&:name).should =~ ["guitar", "bass", "drums"]
    end
  end

  describe "sorting the query" do
    it "remembers the sorting attribute with #sort" do
      query.sort(:username => :asc)
      query.sort_by.should == :username
    end

    it "remembers the sorting direction with #sort" do
      [:asc, :desc, :asc_num, :desc_num].each do |dir|
        query.sort(:username => dir)
        query.sort_dir.should == dir
      end
    end

    it "raises an error if the sorting order is not :asc, :asc_num, descor :desc_num" do
      lambda {
        [:asc, :asc_num, :desc, :desc_num].each do |dir|
          query.sort(:username => dir)
        end
      }.should_not raise_error
      lambda {
        query.sort(:username => :blah)
      }.should raise_error(ArgumentError)
    end
  end

  describe "plucking field values" do
    it "remembers to return instances by default" do
      query = Ricordami::Query.new(Instrument)
      query.to_return.should == Instrument
    end

    it "remembers to pluck field values with #pluck" do
      query.pluck(:id)
      query.to_return.should == :id
      query.store_result.should be_false
    end

    it "remembers to pluck field values but store in redis with #pluck!" do
      query.pluck!(:id)
      query.to_return.should == :id
      query.store_result.should be_true
    end
  end

  describe "creating new objects" do
    before(:each) do
      Instrument.attribute :name
      Instrument.attribute :instrument_type
      Instrument.attribute :difficulty
    end

    it "builds a new object with #build" do
      query.and(:instrument_type => "wind", :name => "flute")
      obj = query.build
      obj.should be_an(Instrument)
      obj.should_not be_persisted
      obj.name.should == "flute"
      obj.instrument_type.should == "wind"
    end

    it "can pass new attributes to #build" do
      query.and(:instrument_type => "wind", :name => "flute")
      obj = query.build(:name => "tuba", :difficulty => "hard")
      obj.instrument_type.should == "wind"
      obj.name.should == "tuba"
      obj.difficulty.should == "hard"
    end

    it "creates a new object with #create" do
      query.and(:instrument_type => "wind", :name => "flute")
      obj = query.create(:name => "tuba", :difficulty => "hard")
      obj.should be_an(Instrument)
      obj.should be_persisted
      obj.instrument_type.should == "wind"
      obj.name.should == "tuba"
      obj.difficulty.should == "hard"
    end
  end
end
