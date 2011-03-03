require "spec_helper"
require "souvenirs/query"

describe Souvenirs::Query do
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
      Instrument.should_receive(:all).with(:expressions => [[:and, {:key => "val"}]])
      query.and(:key => "val").all
    end

    it "delegates #paginate to the runner" do
      Instrument.should_receive(:paginate).with(:expressions => [[:and, {:key => "val"}]], :page => 3, :per_page => 18)
      query.and(:key => "val").paginate(:page => 3, :per_page => 18)
    end

    it "delegates #first to the runner" do
      Instrument.should_receive(:first).with(:expressions => [[:and, {:key => "val"}]],
                                             :sort_by => :key,
                                             :order => "ALPHA ASC")
      query.and(:key => "val").sort(:key).first
    end

    it "delegates #last to the runner" do
      Instrument.should_receive(:last).with(:expressions => [[:and, {:key => "val"}]],
                                            :sort_by => :key,
                                            :order => "ALPHA DESC")
      query.and(:key => "val").sort(:key, :desc_alpha).last
    end

    it "delegates #rand to the runner" do
      Instrument.should_receive(:respond_to?).with(:rand).and_return(true)
      Instrument.should_receive(:rand).with(:expressions => [[:and, {:key => "val"}]],
                                            :sort_by => :key,
                                            :order => "ALPHA ASC")
      query.and(:key => "val").sort(:key).rand
    end

    it "returns the runner if it can't delegate to the runner" do
      Souvenirs::Query.new([]).all.should == []
      Souvenirs::Query.new([]).paginate.should == []
    end

    it "accepts any unknown method and delegate it to the result of #all" do
      instruments = %w(guitar bass drums).map { |value| Struct.new(:name).new(value) }
      Instrument.should_receive(:all).
        with(:expressions => [[:and, {:key => "val"}]]).
        and_return(instruments)
      query.and(:key => "val").map(&:name).should =~ ["guitar", "bass", "drums"]
    end
  end

  describe "sorting the query" do
    it "remembers the sorting attribute with #sort" do
      query.sort(:username)
      query.sort_by.should == :username
    end

    it "remembers the sorting direction with #sort" do
      query.sort(:username)
      query.sort_dir.should == :asc_alpha
      query.sort(:username, :desc_alpha)
      query.sort_dir.should == :desc_alpha
    end

    it "raises an error if the sorting order is not :asc_alpha, :asc_num, desc_alpha or :desc_num" do
      lambda {
        [:asc_alpha, :asc_num, :desc_alpha, :desc_num].each do |dir|
          query.sort(:username, dir)
        end
      }.should_not raise_error(ArgumentError)
      lambda {
        query.sort(:username, :blah)
      }.should raise_error(ArgumentError)
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
