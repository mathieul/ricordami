#!/usr/bin/env ruby

require "thor"
require "thor/actions"

class DataLoader < Thor
  include Thor::Actions

  add_runtime_options!
  check_unknown_options!

  desc "generate_people", "Generate a CSV file of random people"
  method_option :number, :default => 1_000, :desc => "number of people to generate"

  def generate_people
    data_dir = File.expand_path("../../data", __FILE__)
    first_names = read_entries(File.join(data_dir, "first_names.txt"))
    last_names = read_entries(File.join(data_dir, "last_names.txt"))
  end

  private

  def read_entries(path)
    [].tap do |entries|
      File.open(path, "r") do |f|
        f.each_line { |line| entries.push(line.chomp.downcase.capitalize) }
      end
    end
  end
end

require "rubygems" if RUBY_VERSION[0..2].to_f < 1.9

begin
  DataLoader.start
rescue Exception => ex
  STDERR.puts "#{File.basename(__FILE__)}: #{ex}"
  raise
end

