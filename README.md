# Redis-Document: persist ruby objects to Redis #

A simple way to persist Ruby objects into the Redis data structure server.

## Example ##

    class Account
      include Redis::Document

      field :name,      :readonly => true
      field :comments,  :default => "no comments"

      index :name

      validates_presence_of   :name
      validates_uniqueness_of :name

      references_many :operations
    end

    class Operation
      include Redis::Document

      field :type
      field :value

      validates_presence_of   :account

      referenced_in :account
    end
