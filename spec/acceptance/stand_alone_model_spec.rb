require "acceptance_helper"

class Singer
  include Souvenirs::Model

  attribute :username
  attribute :email
  attribute :first_name
  attribute :last_name
  attribute :deceased, :default => "false"

  index :unique => :username, :get_by => true

  validates_presence_of   :username, :email, :deceased
  validates_uniqueness_of :username
  validates_format_of     :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                  :allow_blank => true, :message => "is not a valid email"
  validates_inclusion_of  :deceased, :in => ["true", "false"]
end

feature "Stand-alone model" do
  before(:each) do
    Souvenirs.configure do |c|
      c.redis_host  = "127.0.0.1"
      c.redis_port  = 6379
      c.redis_db    = 1
      c.thread_safe = false
      c.id_type     = :sequence
    end
  end

  scenario "validate, update, save and delete a model" do
    serge = Singer.new
    serge.should_not be_valid
    serge.should have(2).errors
    serge.errors.full_messages.should =~ ["Email can't be blank", "Username can't be blank"]

    serge.email = "what's up?"
    serge.save.should be_false
    serge.errors[:email].should == ["is not a valid email"]

    serge.update_attributes(:username => "lucien", :email => "serge@gainsbourg.com",
                            :first_name => "Serge", :last_name => "Gainsbourg")
    serge.should be_valid
    serge.should be_persisted
    serge.should_not be_a_new_record
    serge.reload.should be_persisted

    lucien = Singer.new(:username => "lucien", :email => "lucien@blahblah.com")
    lucien.should_not be_valid
    lucien.errors.full_messages.should == ["Username is already used"]
    lucien.username = "lucien2"
    lambda { lucien.save! }.should_not raise_error
    lucien.should be_persisted

    Singer.count.should == 2
    deleteme = Singer.get_by_username("lucien2")
    deleteme.delete
    deleteme.should be_deleted
    Singer.count.should == 1
    Singer.get_by_username("lucien").should be_persisted
  end

  scenario "retrieve models" do
    Singer.create!(:username => "lucien", :email => "serge@gainsbourg.com",
                   :first_name => "Serge", :last_name => "Gainsbourg")
    Singer.get_by_username("lucien").id.should == "1"

    Singer.create!(:username => "bashung", :email => "alain@bashung.com",
                   :first_name => "Alain", :last_name => "Bashung")
    Singer.get_by_username("bashung").id.should == "2"

    Singer.create!(:username => "ben", :email => "benjamin@biolay.com",
                   :first_name => "Benjamin", :last_name => "Biolay")
    Singer.get_by_username("ben").id.should == "3"

    Singer.count.should == 3
    #Singer.all.map(&:username).should =~ %w(lucien bashung ben)
    #by_username = Singer.all.map { |u| [u.username, u.id] }
    #by_username = Hash[*by_username.flatten]

    #id = by_username["lucien"]
    #Singer[id].email.should == "serge@gainsbourg.com"
    Singer["1"].email.should == "serge@gainsbourg.com"

    Singer.get_by_username("bashung").first_name.should == "Alain"

    Singer.find(:deceased => true).map(&:username).should =~ ["lucien", "bashung"]
  end

  scenario "dirty state of models"

  scenario "paginate list of models"
end
