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
  config.before(:each) { Souvenirs.driver.flushdb }
end

require spec_dir + "../lib/souvenirs"
