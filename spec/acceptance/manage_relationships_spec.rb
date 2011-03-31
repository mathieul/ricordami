# -*- encoding: utf-8 -*-
require "acceptance_helper"
require "ricordami/can_have_relationships"

class Performer
  include Ricordami::Model
  include Ricordami::CanHaveRelationships

  attribute :first_name
  attribute :last_name

  references_many :albums, :dependent => :delete
end

class Album
  include Ricordami::Model
  include Ricordami::CanHaveRelationships

  attribute :title
  attribute :year, :indexed => :value

  referenced_in :performer
end

feature "Manage relationships" do
  scenario "has many / belongs to" do
    serge = Performer.create(:first_name => "Serge", :last_name => "Gainsbourg")
    serge.albums.create(:title => "Melody Nelson", :year => "1971").should be_true

    marseillaise = serge.albums.build(:title => "Aux Armes et cætera", :year => "1979")
    marseillaise.save.should be_true

    performer = Performer.first
    performer.albums.map(&:title).should =~ ["Melody Nelson", "Aux Armes et cætera"]
    performer.albums.where(:year => "1979").map(&:title).should =~ ["Aux Armes et cætera"]
    performer.albums.sort(:year => :desc_num).map(&:title).should == ["Aux Armes et cætera", "Melody Nelson"]

    Album.all.map(&:title).should =~ ["Melody Nelson", "Aux Armes et cætera"]
    performer.delete
    Album.all.should be_empty
  end
end
