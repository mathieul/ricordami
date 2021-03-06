# Changelog #

## 0.0.6 (???) ##

  - allow to retrieve more than one instance with #get (by passing more
    than one id)
  - basic "references_many :through" implementation that is not optimum
    (instanciates un-necessary through instances) and that doesn't allow
    to chain queries onto the referred method.
  - changed syntax for #sort: Model.sort(:field => <dir>) where <dir> is
    :asc, :desc, :asc_num or :desc_num.
  - added Model#pluck and Model#pluck! to request a list of field values
    instead of a list of instances - the bang version returns a list key
    that contains the result

## 0.0.5 (March 14th, 2011) ##

  - allow to have unique and value indices on the same column so we can
    query fields that have a unique scoped index

## 0.0.4 (March 13th, 2011) ##

  - add a scope option to validates_uniqueness_of validation macro
  - allow to pass nil when creating a new instance
  - added a spec for update_attributes with an invalid model

## 0.0.3 (March 12th, 2011) ##

  - added serialization (use: "model\_can :be_serialized") to have
    access to Model#to_json and Model#to_xml

## 0.0.2 (March 5th, 2011) ##

  - added examples and fixed README
  - created a basic Ricordami::Model#to_s method

## 0.0.1 (March 5th, 2011) ##

Initial release.

Features:

  - keeps track of dirty attributes
  - persist models to 1 Redis instance
  - can include model 1 to 1 and 1 to many relationships
  - can validate with unique index enforced in Redis
  - can query using queries with and/or/not attribute equality conditions
