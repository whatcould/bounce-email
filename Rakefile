require File.dirname(__FILE__) + '/lib/bounce_email'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "bounce-email"
    gemspec.summary = "detect kind of bounced email"
    gemspec.description = "fork of wakiki/bounce-email working with mail gem and ruby 1.9"
    gemspec.email = "pedro.visintin@gmail.com"
    gemspec.homepage = "http://github.com/peterpunk/bounce-email"
    gemspec.authors = ["Agris Ameriks", "Pedro Visintin"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
