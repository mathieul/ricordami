require "acceptance_helper"
require "souvenirs/can_have_relationships"

class Singer
  include Souvenirs::Model
  include Souvenirs::CanHaveRelationships

  attribute :first_name
  attribute :last_name
end

feature "Manage relationships" do
  scenario "has many / belongs to" do
    pending
  end
end
