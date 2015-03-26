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
  :bucket_name
  :username
  :api_key
  :region               # See http://www.rackspace.com/knowledge_center/article/about-regions for options
  :storage_headers      # defaults to {}, can be overridden per-write - see below
  :url_scheme           # defaults to "http"
  :url_host             # defaults to "<bucket-name>.s3.amazonaws.com", or "s3.amazonaws.com/<bucket-name>" if not a valid subdomain
  ```

### Serving directly from S3

  You can get the S3 url using

  ```ruby
  Dragonfly.app.remote_url_for('some/uid')
  ```

  or

  ```ruby
  my_model.attachment.remote_url
  ```

  or with an expiring url:

  ```ruby
  my_model.attachment.remote_url(expires: 3.days.from_now)
  ```

  or with an https url:

  ```ruby
  my_model.attachment.remote_url(scheme: 'https')   # also configurable for all
  urls with 'url_scheme'
  ```

  or with a custom host:

  ```ruby
  my_model.attachment.remote_url(host: 'custom.domain')   # also configurable for
  all urls with 'url_host'
  ```
