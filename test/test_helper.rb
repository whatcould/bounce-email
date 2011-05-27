require 'stringio'
require 'test/unit'
require 'rubygems'

require File.dirname(__FILE__) + '/../lib/bounce_email'

def test_bounce(filename_no_ext)
  file = File.join(File.dirname(__FILE__),'bounces', "#{filename_no_ext}.txt")
  BounceEmail::Mail.new Mail.read(file)
end