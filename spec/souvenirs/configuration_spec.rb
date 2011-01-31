require "spec_helper"

describe Souvenirs::Configuration, " using #configure" do
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
    Souvenirs.configure { |config| config.redis_port = 6379 }
    Souvenirs.configuration.redis_port.should == 6379
  end

  it "can configure redis db (0, 1, 2, ..., 8) with #redis_db" do
    Souvenirs.configure { |config| config.redis_db = 1 }
    Souvenirs.configuration.redis_db.should == 1
  end

  it "can configure redis to use as thread-safe with #redis_thread_safe" do
    Souvenirs.configure { |config| config.redis_thread_safe = true }
    Souvenirs.configuration.redis_db.should be_true
  end

  it "can configure all attributes at once using #from_hash" do
    Souvenirs.configure do |config|
      config.from_hash(:redis_host => "serge",
                       :redis_port => 6380,
                       :redis_db   => 2)
    end
    Souvenirs.configuration.redis_host.should == "serge"
    Souvenirs.configuration.redis_port.should == 6380
    Souvenirs.configuration.redis_db.should == 2
    Souvenirs.configuration.redis_thread_safe.should be_false
  end
end
