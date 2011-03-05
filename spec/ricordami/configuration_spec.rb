require "spec_helper"

describe Ricordami::Configuration, " using #configure" do
  it "raises an error of no block is given" do
    lambda { Ricordami.configure }.should raise_error(ArgumentError)
  end

  it "raises an error when a config attribute doesn't exist" do
    lambda {
      Ricordami.configuration.does_not_exist
    }.should raise_error(Ricordami::AttributeNotSupported)
  end

  it "can configure redis host with #redis_host" do
    Ricordami.configure { |config| config.redis_host = "my_host" }
    Ricordami.configuration.redis_host.should == "my_host"
  end

  it "can configure redis port with #redis_port" do
    Ricordami.configure { |config| config.redis_port = 6379 }
    Ricordami.configuration.redis_port.should == 6379
  end

  it "can configure redis db (0, 1, 2, ..., 8) with #redis_db" do
    Ricordami.configure { |config| config.redis_db = 1 }
    Ricordami.configuration.redis_db.should == 1
  end

  it "can configure redis to use as thread-safe with #thread_safe" do
    Ricordami.configure { |config| config.thread_safe = true }
    Ricordami.configuration.thread_safe.should be_true
  end

  it "can configure all attributes at once using #from_hash" do
    Ricordami.configure do |config|
      config.from_hash(:redis_host => "serge",
                       :redis_port => 6380,
                       :redis_db   => 2)
    end
    Ricordami.configuration.redis_host.should == "serge"
    Ricordami.configuration.redis_port.should == 6380
    Ricordami.configuration.redis_db.should == 2
    Ricordami.configuration.thread_safe.should be_false
  end
end
