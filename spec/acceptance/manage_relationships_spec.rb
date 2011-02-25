require "acceptance_helper"
require "souvenirs/can_have_relationships"

class Singer
  include Souvenirs::Model
  include Souvenirs::CanHaveRelationships

  attribute :first_name
  attribute :last_name

  #references_many :albums, :dependent => :delete
end

class Album
  include Souvenirs::Model
  include Souvenirs::CanHaveRelationships

  attribute :title

  #referenced_in :singer
end

feature "Manage relationships" do
  scenario "has many / belongs to" do
    serge = Singer.create(:first_name => "Serge", :last_name => "Gainsbourg")
    serge.albums.create(:title => "Melody Nelson").should be_true

    marseillaise = serge.albums.build(:title => "Aux Armes etc...")
    marseillaise.save.should be_true

    singer = Singer.first
    singer.albums.map(&:title).should =~ ["Melody Nelson", "Aux Armes etc..."]

    Album.all.map(&:title).should =~ ["Melody Nelson", "Aux Armes etc..."]
    singer.delete
    Album.all.should be_empty
  end
end
