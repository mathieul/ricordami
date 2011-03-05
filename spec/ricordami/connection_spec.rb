require "spec_helper"
require "rspec/mocks"

describe Ricordami::Connection do
  describe "the module" do
    before(:all) do
      module Mixer
        extend self
        include Ricordami::Connection
      end
      RSpec::Mocks::setup(self)
      @config = mock(:config)
      [:redis_host, :redis_port, :redis_db, :thread_safe].each do |name|
        @config.stub!(name)
      end
      Mixer.stub!(:configuration).and_return(@config)
    end

    it "has a connection to Redis" do
      Mixer.driver.should be_a(Redis)
      Mixer.driver.get("not_exist")
      Mixer.driver.client.connection.should be_connected
    end
  end
end
