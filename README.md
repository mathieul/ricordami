# Ricordami: store and query Ruby objects using Redis #

Ricordami ("Remember me" in Italian) is an attempt at providing a simple
interface to build Ruby objects that can be validated, persisted and
queried in a Redis data structure server.


## What does it look like? ##

    require "ricordami"

    Ricordami::Model.configure do |config|
      config.redis_host = "127.0.0.1"
      config.redis_port = 6379
      config.redis_db   = 0
    end

    class Singer
      include Ricordami::Model

      model_can :be_validated, :have_relationships

      attribute :name

      validates_presence_of :name
      validates_uniqueness_of :name

      references_many :songs
    end

    class Song
      include Ricordami::Model

      model_can :be_queried, :have_relationships

      attribute :title, :indexed => :unique, :get_by => true
      attribute :year
    end

    serge = Singer.create :name => "Gainsbourg"
    jetaime = serge.songs.create :title => "Je T'Aime Moi Non Plus", :year => "1967"
    jetaime.year = "1968"
    jetaime.changes  # => {:year => ["1967", "1968"]}
    jetaime.save
    ["La Javanaise", "Melody Nelson", "Love On The Beat"].each do |name|
      serge.songs.create :title => name, :year => "1962"
    end
    Song.get_by_title("Melody Nelson").update_attributes(:year => "1971")
    Song.get_by_title("Love On The Beat").update_attributes(:year => "1984")

    Song.count  # => 3
    Song.where(:year => "1971").map(&:title)  # => "Melody Nelson"


## Why Ricordami? ##

Ricordami's design goal is to find the best trade off between speed and
features. Its syntax goal is to be close enough to ORMs such as Active
Record or Mongoid, so the learning curve stays pretty small.

Ricordami is NOT an attempt at competing with full featured ORMs such as
Active Record or Data Mapper for relational databases, or Mongoid or
Mongo Mapper for MongoDB.

I started Ricordami because I needed to scale and distribute an
event based application accross many servers. I decided to use
the REST-like API micro framework Grape to structure the API, and chose
 Redis to externalize and hold the application state. I needed a library
to structure the data layer and didn't find any library that would work
for me. If I would have searched a bit more I would have found Ohm
(http://ohm.keyvalue.org/) and the story would have stopped here.


## How to install? ##


Ricordami is tested against the following versions of Ruby:

  - MRI 1.9.2
  - Ruby Enterprise 1.8.7
  - Rubinius 1.2.2

and Redis 2.2.x.

Install using bundler:

In your **Gemfile** file:

    gem "ricordami"

And just run:

    $ bundle

Directly with Rubygems:

    $ gem install ricordami

## Features ##

Here is a quick description for each main feature.

### Configuration ###

Ricordami can be configured in two ways. With values stored in the
source code:

    Ricordami::Model.configure do |config|
      config.redis_host  = "redis.lab"
      config.redis_port  = 6379
      config.thread_safe = true
    end

Or using a hash:

    Ricordami.configure do |config|
      config.from_hash(YAML.load("config.yml"))
    end

### Declare a model ###

You just need to require **"ricordami"** and include the
**Ricordami::Model** module into the model class. You can also include
additional features using the class method **#model_can**.

    class Asset
      include Ricordami::Model
      model_can :be_validated,
                :be_queried,
                :have_relationships
    end

### Declare attributes ###

The model state is stored in attributes. Those attributes can be indexed
in order to query the models later on, or enforce the unicity of certain
attributes. Each model gets a default attribute **id** that is a unique
sequence set automatically when the model is saved into Redis. It is
possible to override this attribute by redeclaring it with different
options.

An attribute is declared using the class method **#attribute** and takes
the following options:

  - *:default* - that's the value the attribute will take when it is not
    specified - it can be a value or a Proc (or any object responding to
    **#call**) that will return the value
  - *:initial* - similar to *:default* but rather than used when the
    model is instanciated, it is used when it is persisted to Redis
  - *:read_only* - this attribute can be set only once, after that you
    are certified it will not change
  - *:indexed** - this attribute will be indexed as unique to enforce
    unicity (*:indexed => :unique*) or as value (*:indexed => :value*)
    to allow querying the model (using where/and/any/not)
  - *:type* - attribute type is a string by default (*:string*) but can
    also be an integer (*:integer*) or a float (*:float*)


Example:

    class Person
      include Ricordami::Model
      attribute :name, :default => "First name, Last name"
      attribute :sex,  :indexed => :value
      attribute :age,  :type => :integer
    end

    zhanna = Person.create(:name => "Zhanna", :sex => "Female", :age => 29
    zhanna.id                  # => 42
    Person[42].name            # => "Zhanna"
    Person.get_by_id(42).name  # => "Zhanna"

### Declare indices ###

It is also possible to declare an index using the class method
**#index** to add index specific options, or conditionnaly index an
attribute dynamically. The only option currently supported is *:get_by*
which is used for unique indices in order to request generating
a **get_by_xxx** class method used to fetch a model instance by its
unique value.

Example:

    class Person
      include Ricordami::Model
      attribute :name
      index :name => :unique, :get_by => true
    end

    zhanna = Person.get_by_name("Zhanna")

## How To Run Specs ##

    $ bundle exec rspec spec
    $ rake rspec
    $ bundle exec autotest


### Multiple Ruby Versions ###

Infinity test is like autotest for testing with several versions of Ruby
rather than just one. It requires using rvm to install and manage
multiple Ruby versions.


First you need to install the ruby versions (only install those that are
missing of course). For each version we create a new gemset which
basically acts as a gem sandbox that won't affect the other work you do
on the same machine.

Ruby Enterprise:

    $ rvm install ree-1.8.7-2011.03 # install if necessary
    $ rvm use ree-1.8.7-2011.03
    $ rvm gemset create ricordami
    $ gem install bundler --no-ri --no-rdoc
    $ rvm gemset use ricordami
    $ bundle

Rubinius:

    $ rvm install rbx-1.2.2 # install if necessary
    $ rvm use rbx-1.2.2
    $ rvm gemset create ricordami
    $ rvm gemset use ricordami
    $ gem install bundler --no-ri --no-rdoc
    $ bundle

MRI 1.9.2:

    $ rvm install 1.9.2-p180 # install if necessary
    $ rvm use 1.9.2-p180
    $ rvm gemset create ricordami
    $ rvm gemset use ricordami
    $ gem install bundler --no-ri --no-rdoc
    $ bundle

Run the infinity test:

    $ bundle exec infinity_test


## TODO ##

  * Where to get help - Link to the docs, mailing list, wiki, etc.
  * Contribution guidelines - Tell me how I can help out including wanted features and code standards
  * Contributor list - List the humans behind the project
  * Credits, Inspiration, Alternatives - Tell me if this is a fork of or otherwise inspired by another project. I won’t think you’re a douche when I find out later.

