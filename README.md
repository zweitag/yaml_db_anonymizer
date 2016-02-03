# YamlDb::Anonymizer

Dumps anonymized database contents to a YAML file. This is useful if you want to develop Rails applications with near-live data from your server. Based on [yaml_db](https://github.com/zweitag/yaml_db).

JSON and CSV are supported as alternative serialization formats. Set the environment variable `class=JsonDb::Anonymizer::Helper` or `class=CsvDb::Anonymizer::Helper` respectively in order to use them.

(c) 2012 by Thomas Hollstegge

## Installation

Add this line to your application's Gemfile:

    gem 'yaml_db_anonymizer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaml_db_anonymizer

## Usage

* Specify the database fields to anonymize, e.g. in
   `config/initializers/yaml_db_anonymizer.rb`:

```ruby
YamlDb::Anonymizer.define do
  table :users
    remove :encrypted_password
    replace :name, with: 'John Doe'
    replace :phone, with: ->(phone) { phone.to_s[0..-3] + '***' }
  end

  table :logs do
    truncate
  end
end
```

* Run `rake db:data:dump_anonymized` on your server. This creates an anonymized dump in `db/data.yml`

* Copy `db/data.yml` to your local machine

* Run `rake db:data:load` on your local machine.

## Todo

* Provide capistrano integration

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License. Copyright 2012 by Thomas Hollstegge
