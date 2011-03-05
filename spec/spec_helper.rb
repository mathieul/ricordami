spec_dir = Pathname.new(File.dirname(__FILE__))
$LOAD_PATH.unshift spec_dir

require "rubygems"
require "bundler"

Bundler.setup :default, :test
ENV['RACK_ENV'] ||= "test"

require "rspec"
require "support/constants"
require "support/db_manager"
require "awesome_print"

RSpec.configure do |config|
  config.include Support::Constants
  config.include Support::DbManager
  config.before(:each) do
    Ricordami.configure do |config|
      config.from_hash(:redis_host  => "127.0.0.1",
                       :redis_port  => 6379,
                       :redis_db    => 7,
                       :thread_safe => true)
    end
    Ricordami.driver.flushdb
  end
end

require spec_dir + "../lib/ricordami"
