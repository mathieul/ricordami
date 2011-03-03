require "spec_helper"

describe Souvenirs::Attribute do
    subject { Souvenirs::Attribute }

  describe "an instance" do
    it "has a name" do
      attribute = subject.new(:singer)
      attribute.name.should == :singer
    end

    it "accepts a string for its name" do
      attribute = subject.new("string")
      attribute.name.should == :string
    end

    it "accepts also a symbol for its name" do
      attribute = subject.new(:string)
      attribute.name.should == :string
    end

    it "has an option :default for a default value" do
      attribute = subject.new(:georges, :default => "jungle")
      attribute.default_value.should == "jungle"
    end

    it "doesn't have a default value if :default is not specified" do
      subject.new(:no_defaults).default_value.should be_nil
    end

    it "allows to use a block as a default value for dynamic values" do
      i = 0
      attribute = subject.new(:sequence, :default => Proc.new { i += 1 })
      attribute.default_value.should == 1
      attribute.default_value.should == 2
      attribute.default_value.should == 3
    end

    it "retuns if a default value is set with #default_value?" do
      subject.new(:blah, :default => "1").default_value?.should be_true
      without = subject.new(:foo).default_value?.should be_false
    end

    it "has an option :read_only when the attribute value can only be set once" do
      attribute = subject.new(:georges, :read_only => true)
      attribute.should be_read_only
    end

    it "its value can be set more than once when :read_only is not set" do
      subject.new(:not_read_only).should_not be_read_only
    end

    it "has an option :indexed to index the attribute as unique" do
      attribute = subject.new(:georges, :indexed => :unique)
      attribute.indexed.should == :unique
    end

    it "has an option :indexed to index the attribute by value" do
      attribute = subject.new(:georges, :indexed => :value)
      attribute.indexed.should == :value
    end

    it "raises an error if :indexed is not :unique or :value" do
      lambda {
        subject.new(:georges, :indexed => :blah)
      }.should raise_error(Souvenirs::InvalidIndexDefinition)
      lambda {
        subject.new(:georges)
      }.should_not raise_error
    end

    it "its value can be used for queries when :indexed is not set" do
      subject.new(:not_indexed).should_not be_indexed
    end

    it "has an option :initial for an initial value set when saved the first time" do
      attribute = subject.new(:id, :initial => "123")
      attribute.initial_value.should == "123"
    end

    it "doesn't have an initial value if :initial is not specified" do
      subject.new(:no_initials).initial_value.should be_nil
    end

    it "allows to use a block as an initial value for dynamic values" do
      i = 1
      attribute = subject.new(:id, :initial => Proc.new { i *= 2 })
      attribute.initial_value.should == 2
      attribute.initial_value.should == 4
      attribute.initial_value.should == 8
    end

    it "retuns if an initial value is set with #initial_value?" do
      subject.new(:id, :initial => "1").initial_value?.should be_true
      without = subject.new(:foo).initial_value?.should be_false
    end

    it "can spefify the attribute type with :type option" do
      attribute = subject.new(:id, :type => :integer)
      attribute.type.should == :integer
    end

    it "has a default type :string if not specified" do
      subject.new(:name).type.should == :string
    end

    it "returns the converter method with #converter" do
      subject.new(:name, :type => :string).converter.should == :to_s
      subject.new(:name, :type => :integer).converter.should == :to_i
      subject.new(:name, :type => :float).converter.should == :to_f
    end
  end
end
