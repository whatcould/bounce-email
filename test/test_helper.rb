require 'test/unit'

require File.dirname(__FILE__) + '/../lib/bounce_email'

def test_bounce(filename_no_ext)
  BounceEmail::Mail.read File.join(File.dirname(__FILE__), 'bounces', "#{filename_no_ext}.txt")
end