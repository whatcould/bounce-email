require 'stringio'
require 'test/unit'
require 'rubygems'
require File.dirname(__FILE__) + '/../lib/bounce_email'

def test_email(filename_no_ext)
  path = File.join(File.dirname(__FILE__),'bounces',"#{filename_no_ext}.txt")
  Mail.new(IO.read(path))
end

def test_bounce(filename_no_ext)
  BounceEmail::Mail.new(test_email(filename_no_ext))
end