require 'bundler/setup'
require 'db_schema/definitions'
require 'pry'
require 'awesome_print'
AwesomePrint.pry!

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
