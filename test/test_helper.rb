require 'stringio'
require 'test/unit'
require 'rubygems'
require 'ruby-debug'
require File.dirname(__FILE__) + '/../lib/bounce_email'

def test_email(filename_no_ext, encoding=nil)
  path = File.join(File.dirname(__FILE__),'bounces',"#{filename_no_ext}.txt")
  file = File.open(path, encoding)
  mail = Mail.new(file.read)
  file.close
  mail
end

def test_bounce(filename_no_ext, encoding=nil)
  BounceEmail::Mail.new(test_email(filename_no_ext,encoding))
end