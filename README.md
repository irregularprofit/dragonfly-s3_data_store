# Dragonfly::FogDataStore

  This is shamelessly stolen from
  https://github.com/markevans/dragonfly-s3_data_store.

## Gemfile

  ```ruby
gem 'dragonfly-fog_data_store'
  ```

## Usage

  Configuration (remember the require)

  ```ruby
require 'dragonfly/fog_data_store'

Dragonfly.app.configure do
# ...

datastore :fog,
  container: 'my-container',
  username: 'blahblahblah',
  api_key: 'blublublublu',
  region: 'ord'

# ...
end
  ```

### Available configuration options

  ```ruby
:container
:username
:api_key
:region            # See http://www.rackspace.com/knowledge_center/article/about-regions for options
:storage_headers   # defaults to {}, can be overridden per-write - see below
  ```

