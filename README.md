# ActiveStorage-Memory

Provides an in-memory ActiveStorage service.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activestorage-memory'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activestorage-memory

## Usage

Declare a Memory service in config/storage.yml

```
memory:
  service: Memory
```

To use the Memory service in test, you add the following to config/environments/test.rb:

``` 
config.active_storage.service = :memory
```

In Active Storage's analyzer feature, asynchronous jobs are executed. So you should set the queue adapter to inline at config/environments/test.
```
  config.active_job.queue_adapter = :inline
```

You can read more about Active Storage in the Active Storage Overview guide.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kykt35/activestorage-memory.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
