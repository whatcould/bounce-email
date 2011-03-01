require File.dirname(__FILE__) + '/lib/bounce_email'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rngtng-bounce-email"
    gemspec.summary = "detect kind of bounced email"
    gemspec.description = "fork of whatcould/bounce-email incl. patches from wakiki and peterpunk for working with mail gem and ruby 1.9"
    gemspec.email = "tobi@rngtng.com"
    gemspec.homepage = "http://github.com/rngtng/bounce-email"
    gemspec.authors = ["Tobias Bielohlawek", "Agris Ameriks", "Pedro Visintin"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
