require "spec_helper"

describe Souvenirs::Configuration do
  describe "#configure" do
    it "raises an error of no block is given" do
      lambda { Souvenirs.configure }.should raise_error(ArgumentError)
    end

    it "raises an error when a config attribute doesn't exist" do
      lambda {
        Souvenirs.configuration.does_not_exist
      }.should raise_error(Souvenirs::AttributeNotSupported)
    end

    it "can configure redis host with #redis_host" do
      Souvenirs.configure { |config| config.redis_host = "my_host" }
      Souvenirs.configuration.redis_host.should == "my_host"
    end

    it "can configure redis port with #redis_port" do
      Souvenirs.configure { |config| config.redis_port = "my_port" }
      Souvenirs.configuration.redis_port.should == "my_port"
    end

    it "can configure redis db (0, 1, 2, ..., 8) with #redis_db" do
      Souvenirs.configure { |config| config.redis_db = 2 }
      Souvenirs.configuration.redis_db.should == 2
    end
  end
end
