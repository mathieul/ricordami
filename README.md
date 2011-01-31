# Souvenirs: easily persist ruby models to Redis #

A simple way to persist Ruby models into the Redis data structure server.

## Example ##

    Souvenirs::Model.config

    class Account
      include Souvenirs::Model

      attribute :name,      :readonly => true
      attribute :comments,  :default => "no comments"

      index :name

      validates_presence_of   :name
      validates_uniqueness_of :name

      references_many :operations
    end

    class Operation
      include Souvenirs::Model

      attribute :type
      attribute :value

      validates_presence_of   :account

      referenced_in :account
    end
