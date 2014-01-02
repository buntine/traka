# Traka

A Rails 3+ plugin for simple tracking of changes to resources over time.

Traka will keep track of *create*, *update* and *destroy* actions over time in your application. It uses a simple versioning
system so you can complie groups of changes into blocks.

Changes that cancel each other out will be automatically cleansed from a changeset. For example, if one record is
created and then destroyed later in the same changeset, the two will cancel each other out.

Traka is useful in conjunction with APIs that need to be able to have simple versioning. A common use-case is when your
API needs to send out a succinct changeset when a new version of the data is published. This way your API can send just the data
that has been created/updated/destroyed instead of sending out everything every time.

## Install

```
  gem install traka
  rails g traka:install
  rake db:migrate
```

## Setup

Add the following to each model you want to keep track of:

```ruby 
  is_trakable
```

Each model should have a string "uuid" column. If you want to use a different column name, just specify it:

```ruby 
  is_trakable :traka_uuid => "code"
```

## Use

To access the current set of staged changes:

```ruby 
  Traka::Change.staged_changes #=> [traka_change_record, ...]
```

Each Traka::Change record can be resolved to the original record (except "destroy"):

```ruby 
  Traka::Change.staged_changes.first.get_record #=> record
```

To fetch a changeset across multiple versions. Assuming current version is 5, to get changes from v2 onwards:

```ruby 
  Traka::Change.changes_from(2) #=> [traka_change_record, ...]
```

Or just get changes from v2 to v4:

```ruby 
  Traka::Change.changes_in_range(2, 4) #=> [traka_change_record, ...]
```

The above methods will automatically cleanse obsolete changes. To see everything:

```ruby 
  Traka::Change.staged_changes(false)         #=> [traka_change_record, ...]
  Traka::Change.changes_from(2, false)        #=> [traka_change_record, ...]
  Traka::Change.changes_in_range(2, 4, false) #=> [traka_change_record, ...]
```

To see the current version:

```ruby 
  Traka::Change.latest_version
```

To publish a new version:

```ruby 
  Traka::Change.latest_version       #=> 1
  Traka::Change.publish_new_version!
  Traka::Change.latest_version       #=> 2
```

## Example

Assuming models called Product and Car exist.

```ruby 
  a = Product.create(:name => "Product 1")
  b = Product.create(:name => "Product 2")
  c = Car.create(:name => "Car 1")

  Traka::Change.latest_version #=> 1
  Traka::Change.staged_changes #=> [Traka::Change<create>, Traka::Change<create>, Traka::Change<create>]

  b.name = "New name"
  b.save

  # The "update" above is filtered out because we already know to fetch "b" because it's just been created.
  Traka::Change.staged_changes #=> [Traka::Change<create>, Traka::Change<create>, Traka::Change<create>]

  Traka::Change.publish_new_version!

  Traka::Change.latest_version #=> 2

  b.destroy
  a.name = "New name"
  a.save

  Traka::Change.staged_changes #=> [Traka::Change<destroy>, Traka::Change<update>]
  Traka::Change.staged_changes.last.get_record #=> a

  a.name = "Another name"
  a.save

  # The second update above is filtered because we already know "a" has been updated in this changeset.
  Traka::Change.staged_changes #=> [Traka::Change<destroy>, Traka::Change<update>]
  Traka::Change.staged_changes.last.get_record #=> a

  # All interactions with "b" are filtered out because we've created and destroyed it in the same changeset: v1+v2.
  Traka::Change.changes_from(1) #=> [Traka::Change<create>, Traka::Change<create>, Traka::Change<update>]
```

See the unit tests for a bunch more examples.
