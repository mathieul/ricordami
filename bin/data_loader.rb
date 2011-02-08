#!/usr/bin/env ruby

require "thor"
require "thor/actions"
require "csv"

class DataLoader < Thor
  include Thor::Actions

  add_runtime_options!
  check_unknown_options!

  desc "generate_people FILE_NAME", "Generate a CSV file of random people"
  method_option :number, :aliases => "-n", :default => 1_000, :type => :numeric, :desc => "number of people to generate"

  def generate_people(file_name)
    d = load_data
    CSV.open(file_name, "w") do |csv|
      csv << %w(first_name last_name email)
      options[:number].times do
        f, l = get_first_name(d), get_last_name(d)
        csv << [f, l, get_email(d, f, l)]
      end
    end
    puts "File #{file_name} generated with #{options[:number]} people."
  end

  private

  def load_data
    data_dir = File.expand_path("../../data", __FILE__)
    {
      :first    => read_entries(File.join(data_dir, "first_names.txt")),
      :last     => read_entries(File.join(data_dir, "last_names.txt")),
      :domains  => read_entries(File.join(data_dir, "domains.txt"))
    }
  end

  def read_entries(path)
    [].tap do |entries|
      File.open(path, "r") do |f|
        f.each_line { |line| entries.push(line.chomp.downcase.capitalize) }
      end
    end
  end

  def get_first_name(d)
    d[:first].sample(rand(12) == 3 ? 2 : 1).join(" ")
  end

  def get_last_name(d)
    d[:last].sample
  end

  def get_email(d, f, l)
    one = f[0..(rand(2) - 2)].downcase
    dot = rand(2) == 0 ? "" : "."
    two = l.split.join("-").downcase
    "#{one}#{dot}#{two}@#{d[:domains].sample}"
  end
end

require "rubygems" if RUBY_VERSION[0..2].to_f < 1.9

begin
  DataLoader.start
rescue Exception => ex
  STDERR.puts "#{File.basename(__FILE__)}: #{ex}"
  raise
end

