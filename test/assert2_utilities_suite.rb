require File.dirname(__FILE__) + '/test_helper'


class Assert2UtilitiesSuite < Test::Unit::TestCase

  def setup
    colorize(false)
  end

  def test_assert_classic
    assert_flunk /(false. is not true)|(Failed assertion)/ do
      assert false
    end
  end

  def test_assert_decorates_no_flunks
    complaint = assert_flunk /expected but was/ do
                  assert 'fat chance - we ain\'t Perl!' do
                    assert_equal '42', 42
                  end
                end
    deny{ complaint =~ /fat chance/ }
  end

  def test_assertion_diagnostics
    tattle = "doc says what's the condition?"
    
    assert_flunk /the condition/ do
      x = 43
      assert(tattle){ x == 42 }
    end

    assert_flunk /on a mission/m do
      x = 42
      deny_("I'm a man that's on a mission"){ x == 42 }
    end
  end
  
  def test_assert_diagnose
    x = 42

    assert do
      add_diagnostic{ flunk 'this should never call' } and
      x == 42
    end
  end

  def test_assert_diagose_flunk
    expected = 42
    x = 43

    assert_flunk /^you ain.t #{expected}/ do
      assert do
        add_diagnostic{ "you ain't #{expected}" }
        x == expected
      end
    end
  end

  def test_deny_diagnose
    x = 42
    
    deny do
      add_diagnostic{ flunk 'this should never call' } and
      x == 43
    end
  end

  def test_deny_diagose_flunk
    expected = 42
    x = 42

    assert_flunk /^you ain.t #{expected}/ do
      deny do
        add_diagnostic{ "you ain't #{expected}" } and
        x == expected
      end
    end
  end

  def test_asserts_see_arguments
    x = 42
    assert :args => [42] do |val|
      x == 42
    end
  end

  def test_assert_args
    assert 'the irony /is/ lost on us!',
              :args => [42] do |x|
      assert{ x == 42 }
    end
  end

  def test_consume_diagnostic
    add_diagnostic 'silly Rabbi!'
    assert{ true }

    x = assert_flunk /true/ do
      denigh{ true }
    end

    deny('consume diagnostics at fault time'){ x =~ /silly Rabbi/ }
    add_diagnostic 'silly Rabbi'
    denigh{ false }

    x = assert_flunk /true/ do
          denigh{ true }
        end 
    deny('always consume diagnostics'){ x =~ /silly Rabbi/ }
  end

  def test_trapped_faults_decorate_with_stack_traces
    assert_flunk __FILE__ do
      assert{ 1 / 0 }
    end
  end

  def test_format_inspection
    rf = RubyReflector.new
    assert{ rf.format_inspection('foo'.inspect, 42) == '"foo"' }
    assert{ rf.format_value(42, 'foo') == '"foo"' }
  end

  def test_format_multiline_inspection
    rf = RubyReflector.new
    assert{ rf.format_inspection("foo\nbar", 42) =~ /foo\n\s+bar/ }
  end

  def test_format_literal_multiline_inspection
    return if RUBY_VERSION < '1.9.0'  #  TODO  Ruby 1.8.6 should indent its captures correctly
    rf = RubyReflector.new
    assert{ rf.format_inspection("foo\nbar".inspect, 42) =~ /"foo\\n" \+\n\s+"bar"/ }
    assert{ rf.format_value(42, "foo\nbar") =~ /"foo\\n" \+\n\s+"bar"/ }
  end

end  #  TODO  ultimately, the top of _this_ file should document all of assert{ 2.x }

