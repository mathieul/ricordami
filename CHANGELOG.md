# Changelog #

## 0.0.4 (???) ##

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
