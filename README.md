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

      attribute :name, :readonly => true
      attribute :comments, :default => "no comments"

      index :name

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
