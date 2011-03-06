# Ricordami: store and query Ruby objects using Redis #

Ricordami ("Remember me" in Italian) is an attempt at providing a simple
interface to build Ruby objects that can be validated, persisted and
queried in a Redis data structure server.

<div style="color: red">NOTE: This gem is in active development and is
not ready for use yet.</div>


## What Does It Look Like? ##

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

      referenced_in :singer
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


## How To Install? ##


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

### Declare A Model ###

You just need to require **"ricordami"** and include the
**Ricordami::Model** module into the model class. You can also include
additional features using the class method **#model_can**.

    class Asset
      include Ricordami::Model
      model_can :be_validated,
                :be_queried,
                :have_relationships
    end

### Declare Attributes ###

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

Methods:

  - save: persists the model to Redis (attributes and indices added
    in one atomic operation)
  - update_attributes: update the value of the attributes passed and
    saves the model to Redis
  - delete: deletes the model from Redis (attributes and indices are
    removed in one atomic operation)

### Declare Indices ###

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

### Validation Rules ###

Ricordami relies on the validation capabilities offered by Active Model,
so you can refer to Rails documentation pages for
[ActiveModel::Validations](http://api.rubyonrails.org/classes/ActiveModel/Validations.html) and
[ActiveModel::Validations::HelperMethods](http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html).

Note: when using the **#validates_uniqueness_of** macro, Ricordami
automatically adds a value index to the column it it is not done
already.

Example:

    class Singer
      include Ricordami::Model
      model_can :be_validated

      attribute :username
      attribute :email
      attribute :first_name
      attribute :last_name
      attribute :deceased, :default => "false", :indexed => :value

      validates_presence_of   :username, :email, :deceased
      validates_uniqueness_of :username
      validates_format_of     :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                                      :allow_blank => true, :message => "is not a valid email"
      validates_inclusion_of  :deceased, :in => ["true", "false"]
    end

### Relationships ###

Ricordami handles two kind of relationships: one to one and one to many.
You declare a referrer model to have many of a referenced model using
the class method **#references_many**. It gives the referrer instances
access to an instance method of the plural name of the reference. This
method can be used to fetch the list of reference objects, build or
create a new one, or query the list (see next section for querying).

You declare the referenced method using the class method
**#referenced_in**, which creates one method of the name of the referrer
to fetch it. It also creates two other methods **#build_xxx** and
**#create_xxx** where xxx is the referrer name. Finally it declares a
new attribute *xxx_id* where xxx is the name or the alias of the
referrer.

Finally you can setup a one to one relationship using
**#references_one** and **#referenced_in**. **#references_one** gives
the referrer access to the same type of methods than **#referenced_in**.

Better go with an example to make it all clear:

    class Singer
      include Ricordami::Model
      model_can :have_relationships
      attribute :name

      references_many :songs
    end

    class Song
      include Ricordami::Model
      model_can :have_relationships
      attribute :title

      referenced_in :singer
    end

    bashung = Singer.create(:name => "Alain Bashung")
    bashung.songs  # => []
    osez = bashung.songs.build(:title => "Osez Josephine")
    osez.save
    gaby = bashung.songs.create(:title => "Vertiges de l'Amour")
    bashung.songs.map(&:title)  # => ["Osez Josephine", "Vertiges de l'Amour"]
    gaby.singer_id == bashung.id  # => true

    padam = Song.create(:title => "Padam")
    benjamin = padam.create_singer(:name => "Benjamin Biolay")
    benjamin.songs.map(&:title)  # => "Padam"

The class methods **#references_many**, **#references_one** and
**#referenced_by** can take the following options:

  - *:as* - used to give a different name to the other party in the
    relationship
  - *:alias* - used to give a differnt name of itself to the other party
    in the relationship - there must be a mapping: if A references_many
    B as Ben and B is referenced_in A as Al, references_many must have
    an alias Al and referenced_in must have an alias Ben.
  - *:dependent* - only used for :references_one and :references_many
    relationships - it is possible to set to :nullify so all dependents
    get their referrer id set to nil when the referrer is deleted, or to
    :delete to have them all deleted instead when the referrer is
    deleted

### Basic Queries ###

It is possible to create basic queries and sort the result list of
models. Please note that the queries currently available are quite
limited but might be enhanced in the future. Currently any kind of
querying more advanced than what is described here would have to be
implemented using directly the Redis gem and Redis native commands.

The querying feature adds the following class methods that can be
chained together:

  - *#when*/*#and*: pass a hash of equalities, the result will be the
    list of items that matches ALL the parameter equalities at once
  - *#any*: pass a hash of equalities, the result will be the list of
    items that matches ANY of the parameter equalities
  - *#not*: pass a hash of equalities, the result will be the list of
    items that matches NONE of the parameter equalities
  - *#sort*: sorts the result based on the attribute passed, using the
    default ascending alphanumeric order (:inc_alpha) - the other
    possible orders are: :desc_num, :desc_alpha, :asc_num and :asc
    :desc_alpha
  - *#first*, *#last*, *#rand* and *#all* can be called on any sort
    query result to fetch the desired result

The methods *#and* (and alias *#when*), *#any* and *#not* create
intermediate Redis sets 

Example: we have a tenant model that represent user accounts on a
telephony service application. A tenant has many phone calls that are
made on the platform. Each phone call that goes through the platform is
made from a phone number called the ANI (calling number), to another
phone number called the DNIS (number called). Each call can be using the 
Plain Old Telephone Service (pots) or Voice Over IP (voip), and lasts
for a number of seconds. And finally each call goes through the network
of an operator among AT&amp;T, Qwest and Level3.

    class Tenant
      include Ricordami::Model
      model_can :be_queried, :be_validated, :have_relationships

      attribute :name, :read_only => true
      index :unique => :name, :get_by => true

      references_many :calls, :alias => :owner, :dependent => :delete

      validates_presence_of   :name
      validates_uniqueness_of :name
    end

    class Call
      include Ricordami::Model
      model_can :be_queried, :be_validated, :have_relationships

      attribute :ani,       :indexed => :value
      attribute :dnis,      :indexed => :value
      attribute :call_type, :indexed => :value
      attribute :network,   :indexed => :value
      attribute :seconds,   :type => :integer

      referenced_in :tenant, :as owner

      validates_presence_of  :call_type, :seconds, :owner_id
      validates_inclusion_of :call_type, :in => ["pots", "voip"]
      validates_inclusion_of :network,   :in => ["att", "qwest", "level3"]
    end

    # what is the total number of seconds of the phone calls made from
    # the phone number 650 123 4567?
    Call.where(:ani => "6501234567").inject(0) { |sum, call| sum + call.seconds }

    # what are the VoIP calls that didn't go through Level3 network?
    Call.where(:call_type => "voip").not(:network => "level3").all

    # what are the calls for tenant "mycompany" that went through
    # AT&amp;T's network or originated from ANI 408 123 4567? but were
    # not VoIP calls?
    mycompany = Tenant.get_by_name("mycompany")
    mycompany.calls.any(:ani => "4081234567", :network => "att").not(:call_type => "voip").all


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
    $ rvm gemset use ricordami
    $ gem install bundler --no-ri --no-rdoc
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


## Thanks ##

First of all thanks to Salvatore Sanfilippo ([@antirez](http://twitter.com/antirez))
for Redis. Redis is sucn an amazing application, it makes you want to
write things for it just for the fun of playing with it.

Also I might not have started Ricordami without the amazing work done
and shared by the Rails team, especially DHH, Yehuda Katz and Carl Huda.
ActiveSupport and ActiveModel are just amazingly flexible and so easy to
build on. Also I might never have heard of great resources like
[Grape](https://github.com/intridea/grape) and
[Infinity Test](https://github.com/tomas-stefano/infinity_test) without
the podcasts [Ruby5](http://ruby5.envylabs.com/),
[ChangeLog](http://thechangelog.com/) and [The Ruby Show](http://rubyshow.com/).


## License ##

Released under the MIT License. See the MIT-LICENSE file for further
details.

## Copyright ##

Copyright (c) 2011 Mathieu Lajugie
