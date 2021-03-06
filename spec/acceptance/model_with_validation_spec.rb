require "acceptance_helper"
require "ricordami/can_be_validated"

class Singer
  include Ricordami::Model
  include Ricordami::CanBeValidated

  attribute :username
  attribute :email
  attribute :first_name
  attribute :last_name
  attribute :deceased, :default => "false", :indexed => :value

  index :unique => :username, :get_by => true

  validates_presence_of   :username, :email, :deceased
  validates_uniqueness_of :username
  validates_format_of     :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                  :allow_blank => true, :message => "is not a valid email"
  validates_inclusion_of  :deceased, :in => ["true", "false"]
end

feature "Basic model features with validation" do
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
    lucien.save.should be_true
    lucien.should be_persisted

    Singer.count.should == 2
    deleteme = Singer.get_by_username("lucien2")
    deleteme.delete
    deleteme.should be_deleted
    Singer.count.should == 1
    Singer.get_by_username("lucien").should be_persisted
  end

  scenario "dirty state of models" do
    Singer.create(:username => "bashung", :email => "alain@bashung.com",
                   :first_name => "Alain", :last_name => "Bashung")
    alain = Singer.get_by_username("bashung")
    alain.changed?.should be_false

    alain.first_name = "Bob"
    alain.changed?.should be_true
    alain.first_name_changed?.should be_true
    alain.first_name_was.should == "Alain"
    alain.first_name_change.should == ["Alain", "Bob"]
    alain.changed.should == ["first_name"]
    alain.changes.should == {"first_name" => ["Alain", "Bob"]}

    alain.save
    alain.changed?.should be_false
    alain.first_name_changed?.should be_false
    alain.first_name = "Bob"
    alain.changed?.should be_false
    alain.first_name_changed?.should be_false
    alain.previous_changes.should == {"first_name" => ["Alain", "Bob"]}
  end
end
