require "spec_helper"

describe Souvenirs::Configuration do
  describe "#configure" do
    it "raises an error of no block is given" do
      lambda { Souvenirs.configure }.should raise_error(ArgumentError)
    end

    it "can configure redis host with #redis_host" do
      Souvenirs.configure { |config| config.redis_host = "my_host" }
      Souvenirs.config.redis_host.should == "my_host"
    end
  end
end
