spec_dir = Pathname.new(File.dirname(__FILE__))
$LOAD_PATH.unshift spec_dir

require "rubygems"
require "bundler"

Bundler.setup :default, :test
ENV['RACK_ENV'] ||= "test"

require "support/constants"

RSpec.configure do |config|
  config.include Support::Constants
end

require spec_dir + "../lib/souvenirs"
