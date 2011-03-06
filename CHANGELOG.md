# Changelog #

## 0.0.2 (March 5th, 2011)

  - added examples and fixed README
  - created a basic Ricordami::Model#to_s method

## 0.0.1 (March 5th, 2011)

Initial release.

Features:

  - keeps track of dirty attributes
  - persist models to 1 Redis instance
  - can include model 1 to 1 and 1 to many relationships
  - can validate with unique index enforced in Redis
  - can query using queries with and/or/not attribute equality conditions
