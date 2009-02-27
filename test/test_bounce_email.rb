require File.dirname(__FILE__) + '/test_helper.rb'

class TestBounceEmail < Test::Unit::TestCase

  def test_bounce_type_hard_fail
    bounce = test_bounce('tt_bounce_01')
    assert bounce.code == '5.1.2'
    assert bounce.type == BounceEmail::TYPE_HARD_FAIL
  end
  
  def test_bounce_type_soft_fail
    bounce = test_bounce('tt_bounce_10')
    bounce.code = '4.0.0'
    assert bounce.type == BounceEmail::TYPE_SOFT_FAIL
  end
  
  #  Specific tests
  
  def test_unrouteable_mail_domain
    bounce = test_bounce('tt_bounce_01')
    assert bounce.code == '5.1.2'

    bounce = test_bounce('tt_bounce_02')
    assert bounce.code == '5.1.2'
  end
  
  def test_set_5_0_status
    bounce = test_bounce('tt_bounce_03')
    assert bounce.code == '5.0.0'

    bounce = test_bounce('tt_bounce_04')
    assert bounce.code == '5.0.0'
    
    bounce = test_bounce('tt_bounce_05')
    assert bounce.code == '5.0.0'
  end

  def test_rota_dnsbl # TODO make this more general (match DNSBL only?)
    bounce = test_bounce('tt_bounce_06')
    assert bounce.code == '5.7.1'
  end
  
  # this test email suggests the library fails on this email;
  # mail.part[0] includes a specific status code (5.1.1 User unknown)
  # but the library tests mail.part[1], which returns the general code (5.0.0)
  # either the test email is not a good example, or the parsing could be improved
  def test_user_unknown
    bounce = test_bounce('tt_bounce_07')
    assert bounce.code == '5.0.0'
  end
  
  def test_permanent_failure
    bounce = test_bounce('tt_bounce_08')
    assert bounce.code == '5.3.2'
    
    bounce = test_bounce('tt_bounce_09')
    assert bounce.code == '5.3.2'
  end
  
  def test_undefined_temporary_failure
    bounce = test_bounce('tt_bounce_10')
    assert bounce.code == '4.0.0'
  end
end
