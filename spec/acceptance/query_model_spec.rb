require "acceptance_helper"
require "souvenirs/can_be_queried"

class Singer
  include Souvenirs::Model
  include Souvenirs::CanBeQueried

  attribute :username
  attribute :email
  attribute :first_name
  attribute :last_name
  attribute :deceased, :default => "false", :indexed => :simple

  index :unique => :username, :get_by => true
end

feature "Query model" do
  before(:each) do
    Souvenirs.configure do |c|
      c.redis_host  = "127.0.0.1"
      c.redis_port  = 6379
      c.redis_db    = 1
      c.thread_safe = false
    end
  end

  scenario "retrieve models" do
    Singer.create(:username => "lucien", :email => "serge@gainsbourg.com",
                   :first_name => "Serge", :last_name => "Gainsbourg")
    Singer.get_by_username("lucien").id.should == "1"

    Singer.create(:username => "bashung", :email => "alain@bashung.com",
                   :first_name => "Alain", :last_name => "Bashung")
    Singer.get_by_username("bashung").id.should == "2"

    Singer.create(:username => "ben", :email => "benjamin@biolay.com",
                   :first_name => "Benjamin", :last_name => "Biolay")
    Singer.get_by_username("ben").id.should == "3"

    Singer.count.should == 3
    Singer["1"].email.should == "serge@gainsbourg.com"

    Singer.get_by_username("bashung").first_name.should == "Alain"
  end

  scenario "finding models using basic queries" do
    Singer.create(:username => "ben", :email => "benjamin@biolay.com",
                  :first_name => "Benjamin", :last_name => "Biolay", :deceased => "false")
    Singer.create(:username => "lucien", :email => "serge@gainsbourg.com",
                  :first_name => "Serge", :last_name => "Gainsbourg", :deceased => "true")
    Singer.create(:username => "bashung", :email => "alain@bashung.com",
                  :first_name => "Alain", :last_name => "Bashung", :deceased => "true")

    deceased = Singer.and(:deceased => "true").all
    deceased.map(&:username).should =~ %w(lucien bashung)
    q = Singer.where(:deceased => "true")
    q.sort(:first_name, :asc_alpha).first.email.should == "alain@bashung.com"
    q.sort(:first_name, :desc_alpha).last.email.should == "alain@bashung.com"
    Singer.not(:deceased => true).all.map(&:username).should == ["ben"]
    first = Singer.first.username
    last = Singer.last.username
    rand = Singer.rand.username
    first.should_not == last
    Singer.all.map(&:username).should include(first)
    Singer.all.map(&:username).should include(last)
    Singer.all.map(&:username).should include(rand)
  end

  scenario "paginate list of models" do
    [
      ["Serge", "Gainsbourg"], ["Alain", "Bashung"], ["Benjamin", "Biolay"],
      ["Charles", "Aznavour"], ["Yves", "Montand", true], ["Nino", "Ferrer", true],
      ["Johnny", "Hallyday"], ["David", "Guetta"], ["Bruno", "Benabar"],
      ["Alain", "Souchon"], ["Jacques", "Dutronc"], ["Georges", "Brasens"]
    ].each do |first, last, deceased|
      Singer.create(:username => (first + last[0..0]).downcase, :first_name => first,
                    :last_name => last, :email => "#{first.downcase}@#{last.downcase}.fr",
                    :deceased => deceased ? "true" : "false").should be_persisted
    end
    Singer.count.should == 12

    Singer.paginate(:page => 1, :per_page => 5).should have(5).singers
    Singer.paginate(:page => 2, :per_page => 5).should have(5).singers
    Singer.paginate(:page => 3, :per_page => 5).should have(2).singers
    Singer.paginate(:page => 4, :per_page => 5).should have(0).singers

    page1 = Singer.sort(:last_name, :asc_alpha).paginate(:page => 1, :per_page => 5)
    page1.map(&:last_name).should == ["Aznavour", "Bashung", "Benabar", "Biolay", "Brasens"]
    page3 = Singer.sort(:last_name, :asc_alpha).paginate(:page => 3, :per_page => 5)
    page3.map(&:last_name).should == ["Montand", "Souchon"]
  end
end
