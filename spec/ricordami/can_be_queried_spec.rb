require "spec_helper"
require "ricordami/can_be_queried"

describe Ricordami::CanBeQueried do
  uses_constants("Customer")

  before(:each) do
    Customer.send(:include, Ricordami::CanBeQueried)
    Customer.attribute :country, :indexed => :value
    Customer.attribute :sex,     :indexed => :value
    Customer.attribute :name,    :indexed => :value
    Customer.attribute :kind,    :indexed => :value
    Customer.attribute :age,     :indexed => :value
    Customer.attribute :no_index
    Customer.index :unique => :age, :scope => :kind
  end

  describe "building queries" do
    describe "#and" do
      it "returns a new query" do
        query = Customer.and
        query.should be_a(Ricordami::Query)
      end

      it "passes self as the query runner to the query" do
        query = Customer.and
        query.runner.should == Customer
      end

      it "delegates #and to the new query" do
        query = Customer.and(:key => "value")
        query.filters.should == [[:and, {:key => "value"}]]
      end
    end

    describe "#not" do
      it "returns a new query" do
        query = Customer.not
        query.should be_a(Ricordami::Query)
      end

      it "delegates #not to the new query" do
        query = Customer.not(:key => "value")
        query.filters.should == [[:not, {:key => "value"}]]
      end
    end

    describe "#any" do
      it "returns a new query" do
        query = Customer.any
        query.should be_a(Ricordami::Query)
      end

      it "delegates #any to the new query" do
        query = Customer.any(:key => "value")
        query.filters.should == [[:any, {:key => "value"}]]
      end
    end

    describe "#sort" do
      it "returns a new query" do
        query = Customer.sort(:sex => :asc)
        query.should be_a(Ricordami::Query)
      end

      it "delegates #sort to the new query" do
        query = Customer.sort(:sex => :desc)
        query.sort_by.should == :sex
        query.sort_dir.should == :desc
      end
    end

    describe "#pluck & #pluck!" do
      it "returns a new query" do
        query = Customer.pluck(:id)
        query.should be_a(Ricordami::Query)

        query = Customer.pluck!(:id)
        query.should be_a(Ricordami::Query)
      end

      it "delegates #pluck to the new query" do
        query = Customer.pluck(:id)
        query.to_return.should == :id
        query.store_result.should be_false

        query = Customer.pluck!(:id)
        query.to_return.should == :id
        query.store_result.should be_true
      end
    end
  end

  describe "running queries" do
    before(:each) do
      Customer.create(:id => "1", :name => "Zhanna", :sex => "F", :country => "Latvia", :kind => "human", :age => "29")
      Customer.create(:id => "2", :name => "Mathieu", :sex => "M", :country => "France", :kind => "human", :age => "40")
      Customer.create(:id => "3", :name => "Sophie", :sex => "F", :country => "USA", :kind => "human", :age => "1")
      Customer.create(:id => "4", :name => "Brioche", :sex => "F", :country => "USA", :kind => "dog", :age => "3")
    end

    describe ":and" do
      it "raises an error if there's no value index for one of the conditions" do
        lambda {
          Customer.and(:no_index => "Blah").all
        }.should raise_error(Ricordami::MissingIndex)
      end

      it "returns all entries if no conditions where passed" do
        Customer.and.all.map(&:name).should =~ %w(Zhanna Mathieu Sophie Brioche)
      end

      it "returns the models found with #all (1 condition, 1 result)" do
        Customer.index :value => :name
        found = Customer.and(:name => "Zhanna").all
        found.map(&:name).should == ["Zhanna"]
      end

      it "allows to specify a list of values instead of just one value" do
        Customer.index :value => :name
        Customer.index :value => :sex
        found = Customer.and(:name => ["Zhanna", "Brioche", "Mathieu"], :sex => "F").all
        found.map(&:name).should =~ ["Zhanna", "Brioche"]
        found = Customer.and(:name => ["Zhanna", "Brioche", "Mathieu"], :sex => "M").all
        found.map(&:name).should =~ ["Mathieu"]
      end

      it "allows to specify a list of ids as a nested OR condition" do
        found = Customer.where(:id => ["1", "4"]).all
        found.map(&:name).should =~ ["Zhanna", "Brioche"]
      end

      it "returns the models found with #all (2 conditions, 2 results)" do
        found = Customer.and(:country => "USA", :sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
      end

      it "returns the models found with #all for a composed query" do
        found = Customer.and(:country => "USA").and(:sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
      end

      it "can use #where instead of #and" do
        found = Customer.where(:country => "USA").and(:sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
      end

      it "doesn't require #all if another method call is chained" do
        Customer.where(:country => "USA").and(:sex => "F").map(&:name).should =~ ["Sophie", "Brioche"]
      end

      it "can run a query on attributes with unique indices (if they also have a value index of course)" do
        Customer.where(:country => "USA", :age => "1").map(&:name).should == ["Sophie"]
      end

      it "returns ids when using #pluck with :id" do
        Customer.where(:country => "USA").and(:sex => "F").pluck(:id).all.should =~ ["3", "4"]
      end

      it "returns the field values when using #pluck with a field name" do
        Customer.where(:country => "USA").and(:sex => "F").pluck(:name).all.should =~ ["Sophie", "Brioche"]
      end

      it "returns a key with the ids when using #pluck! with :id" do
        key = Customer.where(:country => "USA").and(:sex => "F").pluck!(:id).all
        Customer.redis.lrange(key, 0, -1).should =~ ["3", "4"]
      end

      it "returns a key with the field values when using #pluck! with a field name" do
        key = Customer.where(:country => "USA").and(:sex => "F").pluck!(:name).all
        Customer.redis.lrange(key, 0, -1).should =~ ["Sophie", "Brioche"]
      end
    end

    describe ":any" do
      it "raises an error if there's no value index for one of the conditions" do
        lambda {
          Customer.any(:no_index => "Blah").all
        }.should raise_error(Ricordami::MissingIndex)
      end

      it "returns all entries if no conditions where passed" do
        Customer.any.all.map(&:name).should =~ %w(Zhanna Mathieu Sophie Brioche)
      end

      it "returns the models found with #all (1 condition, 1 result)" do
        Customer.index :value => :name
        found = Customer.any(:name => "Zhanna").all
        found.map(&:name).should == ["Zhanna"]
      end

      it "returns the models found with #all (2 conditions, 3 results)" do
        found = Customer.any(:country => "USA", :sex => "F").all
        found.map(&:name).should =~ ["Sophie", "Brioche", "Zhanna"]
      end

      it "returns the models found with #all for a composed query" do
        found = Customer.where(:country => "USA").any(:name => "Sophie", :kind => "dog").all
        found.map(&:name).should =~ ["Sophie", "Brioche"]
        found = Customer.where(:country => "USA").any(:name => "Sophie", :kind => "human").all
        found.map(&:name).should == ["Sophie"]
      end

      it "doesn't require #all if another method call is chained" do
        Customer.any(:country => "USA", :sex => "F").map(&:name).should =~ ["Sophie", "Brioche", "Zhanna"]
      end
    end

    describe ":not" do
      it "raises an error if there's no value index for one of the conditions" do
        lambda {
          Customer.not(:no_index => "Blah").all
        }.should raise_error(Ricordami::MissingIndex)
      end

      it "returns all entries if no conditions where passed" do
        Customer.not.all.map(&:name).should =~ %w(Zhanna Mathieu Sophie Brioche)
      end

      it "returns the models found with #all (1 condition, 1 result)" do
        Customer.index :value => :name
        found = Customer.not(:name => "Zhanna").all
        found.map(&:name).should =~ ["Sophie", "Brioche", "Mathieu"]
      end

      it "returns the models found with #all (2 conditions, 1 result)" do
        found = Customer.not(:country => "USA", :sex => "F").all
        found.map(&:name).should == ["Mathieu"]
      end

      it "returns the models found with #all for a composed query" do
        found = Customer.where(:country => "USA").not(:name => "Sophie", :kind => "dog").all
        found.map(&:name).should be_empty
        found = Customer.where(:country => "USA").not(:name => "Sophie", :kind => "human").all
        found.map(&:name).should == ["Brioche"]
      end

      it "doesn't require #all if another method call is chained" do
        Customer.not(:country => "USA", :sex => "F").map(&:name).should == ["Mathieu"]
      end
    end
  end

  describe "sorting result" do
    uses_constants("Student")

    before(:each) do
      Student.send(:include, Ricordami::CanBeQueried)
      Student.attribute :name,    :indexed => :value
      Student.attribute :grade,   :indexed => :value
      Student.attribute :school,  :indexed => :value
      [["Zhanna", 12], ["Sophie", 19],
       ["Brioche", 4], ["Mathieu", 15]].each do |name, grade|
         Student.create(:name => name, :grade => grade, :school => "Lajoo")
       end
    end

    it "can sort the result alphanumerically with #sort" do
      result = Student.where(:school => "Lajoo").sort(:name => :asc)
      result.map(&:name).should == %w(Brioche Mathieu Sophie Zhanna)
    end

    it "can sort the result numerically with #sort" do
      result = Student.where(:school => "Lajoo").sort(:grade => :asc_num)
      result.map(&:name).should == %w(Brioche Zhanna Mathieu Sophie)
    end
  end

  describe "fetching result" do
    before(:each) do
      Student.send(:include, Ricordami::CanBeQueried)
      Student.attribute :name,    :indexed => :value
      Student.attribute :grade,   :indexed => :value
      Student.attribute :school,  :indexed => :value
      [["Zhanna", 12], ["Sophie", 19],
       ["Brioche", 4], ["Mathieu", 15]].each do |name, grade|
         Student.create(:name => name, :grade => grade, :school => "Lajoo")
       end
      @query = Student.where(:school => "Lajoo").sort(:name => :asc)
    end
    let(:query) { @query }

    it "fetches all the results with #all" do
      query.all.map(&:name).should == %w(Brioche Mathieu Sophie Zhanna)
    end

    it "fetches the requested page of the results with #paginate" do
      fetched = query.paginate(:page => 1, :per_page => 2)
      fetched.map(&:name).should == %w(Brioche Mathieu)
      fetched = query.paginate(:page => 2, :per_page => 2)
      fetched.map(&:name).should == %w(Sophie Zhanna)
      query.paginate(:page => 3, :per_page => 2).should be_empty
    end

    it "fetches the first instance with #first" do
      query.first.name.should == "Brioche"
    end

    it "fetches the last instance with #last" do
      query.last.name.should == "Zhanna"
    end

    it "fetches a random instance with #rand" do
      %w(Brioche Mathieu Sophie Zhanna).should include(query.rand.name)
    end
  end
end
