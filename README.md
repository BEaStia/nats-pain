# Nats::Pain

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nats/pain`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nats-pain'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nats-pain

## Usage

This gem simplifies usage of nats and nats-streaming in pair.

In Iconjob company we have created a very exact delivering nats message system.

Firstly it tries to send message with Nats-streaming, then with regular nats.
All messages have their own transactions. 

So consuming services would not make any duplications. **It's strongly recommended to be implemented!**

### Environment Variables
* PAIN_NATS_ENABLED - is nats enabled or not. Default: `true`
* PAIN_NATS_POOL_SIZE - size of the connection pool. Default: `5`
* PAIN_NATS_POOL_TIMEOUT - timeout in seconds for pool. Default: `5`

* PAIN_STAN_ENABLED - is stan enabled or not. Default: `true`
* PAIN_STAN_POOL_SIZE - size of the connection pool. Default: `5`
* PAIN_STAN_POOL_TIMEOUT - timeout in seconds for pool. Default: `5`

* NATS_SERVICE_NAME - name of service that is using this gem. Default: `painful_service`
* NATS_SERVERS_URLS - array of nats servers to connect with. Default: `nats://localhost:4222`
* STAN_SERVERS_URLS - array of stan servers to connect with. Default: `nats://localhost:4223`
* STAN_CLUSTER_NAME - name of stan cluster to connect with. Default: `worki_cluster`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nats-pain. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Nats::Pain project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/nats-pain/blob/master/CODE_OF_CONDUCT.md).
