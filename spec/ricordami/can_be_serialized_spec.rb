require "spec_helper"
require "ricordami/can_be_serialized"

describe Ricordami::CanBeSerialized do
  uses_constants("User", "Car")

  it "returns a JSON representation string with #to_json" do
    User.model_can :be_serialized
    User.attribute :name
    User.attribute :age
    zhanna = User.create(:id => "plou", :name => "Zhannulia", :age => 29)
    decoded = ActiveSupport::JSON.decode(zhanna.to_json)
    decoded.should == {"user" => {"id" => "plou", "name" => "Zhannulia", "age" => "29"}}
  end

  it "returns a XML representation string with #to_xml" do
    Car.model_can :be_serialized
    new_car = Car.create(:id => "prius")
    new_car.to_xml.should ==<<EOS
<?xml version="1.0" encoding="UTF-8"?>
<car>
  <id>prius</id>
</car>
EOS
  end
end
