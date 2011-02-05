# Souvenirs: easily persist ruby models to Redis #

A simple way to persist Ruby models into the Redis data structure server.

## Example ##

    Souvenirs::Model.configure do |config|
      config.redis_host = "127.0.0.1"
      config.redis_port = 6379
      config.redis_db   = 0
    end

    class Account
      include Souvenirs::Model

      attribute :name, :read_only => true
      attribute :comments, :default => "no comments"

      index :unique => :name

      validates_presence_of :name
      validates_uniqueness_of :name

      references_many :operations
    end

    class Operation
      include Souvenirs::Model

      attribute :type
      attribute :value

      validates_presence_of :account

      referenced_in :account
    end

    account = Account.new(:name => "test", :comments => "testing...")
    account.save
    operation = Operation.new(:account => account, :type => "debit", :value => "$99.99")
    operation.save

## TODO ##

  * Description - I’m surprised at how many times I land on a project page that is obviously popular (because Twitter told me so) but I have no idea why because the project owners don’t tell me plainly what the project is or why I should care.
  * Installation instructions - Tell me where to get the bits and how to install them
  * Where to get help - Link to the docs, mailing list, wiki, etc.
  * Contribution guidelines - Tell me how I can help out including wanted features and code standards
  * Contributor list - List the humans behind the project
  * Credits, Inspiration, Alternatives - Tell me if this is a fork of or otherwise inspired by another project. I won’t think you’re a douche when I find out later.

# RENAMING #

Possible names:

  * Memoria     (memory)
  * Ricordi     (memories)
  * Ricordami   (remember me)

