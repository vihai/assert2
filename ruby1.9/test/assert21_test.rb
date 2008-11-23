require 'test/unit'
$:.unshift 'lib'; $:.unshift '../lib'
require 'assert21'
require 'assert_flunk'

class Assert21Suite < Test::Unit::TestCase

  def setup
    @effect = Test::Unit::Assertions::AssertionRipper.new()
    array = [1, 3]
    hash = { :x => 42, 43 => 44 }
    x = 42
    @effect.block = lambda{x}
  end
  
  def test_assert_args
    assert 'the irony /is/ lost on us!', 
              :args => [42] do |x|
      assert{ x == 42 }
    end
  end
  
  def test_assert_args_flunk
    assert_flunk /x.*--> 42/ do
      assert nil, :args => [42] do |x|
        x == 43
      end
    end
  end
  
  def test_deny_args_flunk
    assert_flunk /x.*--> 42/ do
      deny nil, :args => [42] do |x|
        x == 42
      end
    end
  end

  def test_assert_diagnose
    x = 42

    assert nil, :diagnose => 
        lambda{ flunk 'this should never call' } do
      x == 42
    end
  end
  
  def test_assert_diagose_flunk
    expected = 42
    x = 43
    
    assert_flunk /you ain.t #{expected}/ do
      assert nil, :diagnose => lambda{ "you ain't #{expected}" } do
        x == expected
      end
    end
  end
  
  def test_deny_diagnose
    x = 42
    deny nil, :diagnose => 
        lambda{ flunk 'this should never call' } do
      x == 43
    end
  end
  
  def test_deny_diagose_flunk
    expected = 42
    x = 42
    
    assert_flunk /you ain.t #{expected}/ do
      deny nil, :diagnose => lambda{ "you ain't #{expected}" } do
        x == expected
      end
    end
  end
  
  def test_pass_args_to_detector
    @effect.captured_block_vars = 'x, y'
    @effect.args = [40, 2]
    assert{ @effect.detect('x + y') == 42 }   
  end
  
  def test_captures
    assert_assert 'x', 42
    assert_assert '~x', ~42
    assert_assert 'x + 1', 43
    assert_assert 'x + (1 * 2)', 44
    assert_assert 'x.to_s', '42'
    assert_assert 'Time.at(x)', Time.at(42)
    assert_assert 'require "assert21.rb"', false
    assert_assert '42.times.inject{ |x, b| b + x }', 861
    assert_assert 'array.first', 1
    assert_assert 'array[1]', 3
    assert_assert 'hash[:x]', 42
    assert_assert 'hash[43]', 44
    assert_assert 'array[0..1]', [1,3][0..1]
    assert_assert 'array[0...1]', [1,3][0...1]
    assert_reflect '"span[ @class = \"delimiter\" ]"'
    assert_reflect '\'span[ @class = "delimiter" ]\'', "\"span[ @class = \\\"delimiter\\\" ]\""
    assert_reflect "'span[ @class = \"delomiter\" ]'", "\"span[ @class = \\\"delomiter\\\" ]\""
    assert_assert "daZone(\"string \\\"nested\\\"\")", nil
    assert_reflect "daZone('string \\\"nested\\\"')", "daZone(\"string \\\"nested\\\"\")"
    assert_reflect "daZone('string \"nested\"')", "daZone(\"string \\\"nested\\\"\")"
  end
    
  def daZone( whatever );  
    add_diagnostic 'daybreak on the land'
    return nil
  end

  def test_daZone
    assert_flunk /daybreak on the land.*nested/m do
      assert{ daZone("string \"nested\"") }
    end

    message = assert_flunk /nested/ do
                assert{ daZone('string "nested"') }
              end
    deny{ message =~ /SyntaxError/ }
  end

  def test_format_assertion_result
    value = "if the thunder don't catch ya\nthen the lighting will"
    sample = @effect.format_assertion_result('mission accomplished', value)
    assert{ sample == "mission accomplished\n" +
                      " --> if the thunder don't catch ya\n" +
                      "     then the lighting will\n" }
    sample = @effect.format_assertion_result("mission\naccomplished", value)
    assert{ sample == "mission\n" +
                      "accomplished\n" +
                      " --> if the thunder don't catch ya\n" +
                      "     then the lighting will\n" }
  end

  def assert_assert(source, match)
    assert_reflect source
    assert_capture source, match
  end
  
  def _test_rip_thyself
    home = File.dirname(__FILE__)
    
    Dir[home + '/*.rb'].each do |file|
      assert_rip_file home + '/' + file
    end
  end

  def assert_rip_file(filename)
    rippage = Ripper.sexp(File.read(filename))
    @effect.block = nil 
    rippage.last.each do |statement|
      @effect.sender statement
    end
  end

  def assert_reflect(sauce, match = sauce)
    @effect.captures.replace []
    @effect.reflect.replace ''
    @effect.ripped = @effect.rip(sauce)
    @effect.sender @effect.ripped.first
    
    if match.kind_of? Regexp
      assert{ @effect.reflect =~ match }
    else
      assert{ @effect.reflect.index(match) }
    end
  end

  def test_reflections
    assert_reflect "module Foo\n\nend"
    assert_reflect "begin\n$1\nrescue => e\nend"
    assert_reflect "begin\n$0\nrescue RuntimeError => e\nend"
    assert_reflect "begin\n$!\nrescue RuntimeError, NameError => e\nend"
    assert_reflect "begin\n\nrescue RuntimeError, NameError\nend"
    assert_reflect "begin\n\nrescue RuntimeError\nend"
    assert_reflect 'exceptions, modules = args, []'
    assert_reflect 'require "foo"'
    assert_reflect '[52, 21]'
    assert_reflect '[52, [:symbol, object], 2]'
    assert_reflect 'require("foo")'
    assert_reflect 'pp require "foo"'
    assert_reflect 'pp require("foo")'
    assert_reflect "if foo\nbar\nelse\nbaz\nend"
    assert_reflect "unless foo\nbar\nelse\nbaz\nend"
    assert_reflect "foo.each do\n|q| break\n\nend"
    assert_reflect "for x in foo\nbreak\n\nend"
    assert_reflect "until x == 43\nbreak\n\nend"
    assert_reflect "while x == 43\nbreak\n\nend"
    assert_reflect "begin\ncatch\nrescue\nensure\nthrow\nend"
    assert_reflect "if foo\nbar\nelse\nbaz\nend"
    assert_reflect "if foo\nbar\nelsif v\nbaz\nend"
    assert_reflect "x = foo ? bar : baz"
    assert_reflect "foo ? bar : baz"
    assert_reflect "def foo()\nx = yield\nend"
    assert_reflect "def foo()\nreturn\nend"
    assert_reflect "def foo()\nreturn bar(42)\nend"
    assert_reflect 'x ||= @ivar'
    assert_reflect 'x = :symbol.to_s'
    assert_reflect "(x\n42)"
    assert_reflect "(x;nil)", "(x\nnil)"
    assert_reflect "class Foo < Baz\n\n\nend"
    assert_reflect "class Foo\ndef bar()\n\nend\n\nend"
    assert_reflect "def foo(*args)\n42\nend"
    assert_reflect "def foo(args, *stuff)\n42\nend"
    assert_reflect "def foo(*args, &block)\n42\nend"
    assert_reflect "def foo(args, *stuff, &block)\nyield(42)\nend"
    assert_reflect "def foo args, *stuff\n42\nend"
    assert_reflect "def foo *args, &block\n42\nend"
    assert_reflect "def foo args, *stuff, &block\nyield(42)\nend"
    assert_reflect 'def foo; 42; end', "def foo\n42\nend"
    assert_reflect "class foo\ndef bar\n\nend\n\nend"
    assert_reflect "assert{ x == 42 }"
    assert_reflect "inject :hash => \"options\""
    assert_reflect 'inject hash: "options"', "inject :hash => \"options\""
    assert_reflect "naughty{ |zone| x == 42 }"
    assert_reflect "naughty{ |zone, (what, ever), *stuff, &block|  }"
    assert_reflect "naughty{ |*stuff, &block|  }"
    assert_reflect "naughty{ |zone, (what, ever), &block|  }"
    assert_reflect "naughty{ |zone, (what, ever), *stuff|  }"
    assert_reflect "naughty{ |&block|  }"
    assert_reflect "naughty{ |*stuff|  }"
    assert_reflect "naughty{ |zone, (what, ever)|  }"
    assert_reflect "assert do\nx == 42\nend"
    assert_reflect "assert do\nx == 42\n42 == x\nend"
    assert_reflect "x = lambda do\nx == 42\nend"
  end
  
  def test_reflections_two
    assert_reflect "x.call(15)"
    assert_reflect "[42, *args].call(\"yo\")"
    assert_reflect "[42, *args].call \"yo\""
    assert_reflect "yo.call \"yo\", dude, &block"
    assert_reflect "fribberty(\"yo\", dude, *stuff, &block)"
    assert_reflect "fribberty(dude, *stuff, &block)"
    assert_reflect "fribberty(*stuff, &block)"
    assert_reflect "fribberty(dude, &block)"
    assert_reflect "fribberty(&block)"
    assert_reflect "fribberty \"yo\", dude, *stuff, &block"
    assert_reflect "fribberty dude, *stuff, &block"
    assert_reflect "fribberty *stuff, &block"
    assert_reflect "fribberty dude, &block"
    assert_reflect "fribberty &block"
    assert_reflect "[42, *args].call(\"yo\", &block)"
    assert_reflect "/vacuous dialectic/"
    assert_reflect '/vacuous #{ dialectic }/'
    assert_reflect "array[:yo] = 42"
    assert_reflect "array[:yo] ||= 42"
    assert_reflect ":'symbol'", ":\"symbol\""
    assert_reflect ':"symbol\ntoo"'
    assert_reflect '"mashed#{ 42 }string"'
    assert_reflect '"mashed#{ \'43\' }string"', "\"mashed\#{ \"43\" }string\""
    assert_reflect '"mashed#{ "43" }string"'
    assert_reflect '"mashed#{ "43".length }string"'
    assert_reflect '"mashed#{ "nested#{ 42 }mashed" }string"'
    assert_reflect '"mashed#{ "nested#{ "42" }mashed" }string"'
  end
  
  def test_reflections_three
    assert_reflect ':"symbol#{ 42 }"'
    assert_reflect 'foo = %w{ c30 c60 c90 }', "foo = [ \"c30\", \"c60\", \"c90\" ]"
    assert_reflect '%w{ c30 c60 c90 }.bar', "[ \"c30\", \"c60\", \"c90\" ].bar"
    assert_reflect "@element.call()"
    assert_reflect "@element ||= false"
    assert_reflect "self.element = true"
    assert_reflect "x = {  }"
    assert_reflect "{  }"
    assert_reflect "{ x => 42 }"
    assert_reflect "{ x => 42, :y => 43 }"
    assert_reflect "x # 42", 'x'
    assert_reflect "/i got da power/"
    assert_reflect "\"power\" =~ /pow/"
    assert_reflect "foo if q"
    assert_reflect "foo unless not q"
    assert_reflect '"yo" \'dude\'', '"yo" "dude"'
    assert_reflect "def nil.__assertion_diagnostic\nreturn \"daybreak on the land\"\nend\n"
    # assert_reflect "x = <<EOT\nyo\nEOT"
    assert_reflect "'\"yo\"'", "\"\\\"yo\\\"\""
    assert_reflect "x = *options[:args]"
    assert_reflect 'Class.new("yo"){ |block| p block }'
    assert_reflect "def naughty\nsuper(42)\nyield\nend"
    assert_reflect "def naughty\nsuper\nyield(42)\nend"
  end
  
  def test_trailing_nonsense_in_goal_posts
    assert_reflect 'naughty{ |zone, (what, ever), *stuff, &block|  }'
  end

  def test_detect_errors
    assert{ @effect.detect('x') == 42 }
    
    assert do 
      @effect.detect('foo') =~
        /NameError: undefined local variable or method `foo'/
    end
  end

  def test_add_diagnostic
    add_diagnostic 'silly Rabbi'
    
    assert_flunk /silly Rabbi/ do
      denigh{ true }
    end
     
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

  def test_const_ref
    rippage = [:const_ref, [:@const, "Assert21Suite", [5, 6]]]
    @effect.sender rippage
    assert_capture 'Assert21Suite', Assert21Suite
    rippage = [:const_path_ref,
               [:const_path_ref,
                [:var_ref, [:@const, "Test", [5, 22]]],
                [:@const, "Unit", [5, 28]]],
                [:@const, "TestCase", [5, 34]]]
    @effect.sender rippage
    assert_match 'Test::Unit::TestCase', @effect.reflect
    assert_capture 'Test', Test
    assert_capture 'Test::Unit', Test::Unit
    assert_capture 'Test::Unit::TestCase', Test::Unit::TestCase
  end

  def test_format_snip
    long_snip = 'really.really.really.really.reallyreally.long.expression'

    assert{ @effect.format_snip(60, long_snip) == 
                   '    really.really.really.really.reallyreally.long.expression' }

    assert{ @effect.format_snip(35, long_snip) == 
              "       really.really.really.really.\n" +
              "       reallyreally.long.expression" }
  end

  def test_format_value
    long_capture = 'really.really.really.really.reallyreally.long.expression'
    value = @effect.rip(long_capture) # because it's big and nesty
    #assert{ value == 42 }
    pretty = @effect.format_value(25, value)
    assert{ pretty =~ /:call,\n/ }
    line = pretty.split("\n")[1]
    assert{ line =~ /\s{28}  \[/ }
  end

#  CONSIDER  system to censor : marks to foil stoopid TextMate bug

  def test_capture_mashed_strings
    assert_reflect 'x'
    assert{ @effect.captures == [['x', 42]] }
    assert_reflect source = '"invisible"'
    assert{ @effect.captures.empty? }
    assert_reflect source = '"vis#{ 42 }le"'
    assert{ @effect.captures == [[source, 'vis42le']] }
    assert_reflect source = '"vis#{ x }le"'
    assert{ @effect.captures.index [source, 'vis42le'] }
    assert_reflect source = '"vis#{ "ib" }le"'
    assert{ @effect.captures == [[source, 'visible']] }
  end

  def test_capture_mashed_regices
    assert_reflect source = '/invisible/'
    assert{ @effect.captures.empty? }
    assert_reflect source = '/vis#{ 42 }le/'
    assert{ @effect.captures == [[source, /vis42le/]] }
    assert_reflect source = '/vis#{ x }le/'
    assert{ @effect.captures.index [source, /vis42le/] }
    assert_reflect source = '/vis#{ "ib" }le/'
    assert{ @effect.captures == [[source, /visible/]] }
  end

  def assert_capture(symbol, value)
    @effect.captures.each do |k,v|
      if k == symbol
        assert "seeking #{symbol}" do
          if value.kind_of? Regexp
            v =~ value
          else
            v == value
          end
        end
        return
      end
    end
    
    flunk "#{symbol} not found in\n" +
            @effect.captures.pretty_inspect +
            "\ndespite all of " +
            @effect.ripped.pretty_inspect
  end

  def test_extract_brace_block
    rippage = @effect.rip('assert{ x == 42 }')
    brace_block = @effect.extract_block(rippage)
    assert do
      brace_block == 
             [[:binary,
               [:var_ref, [:@ident, "x", [1, 8]]],
               :==,
               [:@int, "42", [1, 13]]
               ]]
    end
  end

  def test_extract_brace_block_and_capture_arguments
    rippage = @effect.rip('assert{ |x, y| x == y }')
    @effect.extract_block(rippage)
    assert{ @effect.captured_block_vars == 'x, y' }
  end

  def test_rip_entire_assertion
    rippage = @effect.rip('assert{ x == 42 }')
    
    assert do
      rippage == 
          [[:method_add_block,
            [:method_add_arg, [:fcall, [:@ident, "assert", [1, 0]]], []],
            [:brace_block,
             nil,
             [[:binary,
               [:var_ref, [:@ident, "x", [1, 8]]],
               :==,
               [:@int, "42", [1, 13]]
               ]]
            ]
          ]]
    end
  end

  def test_cant_rip_entire_assertion
    x = assert_raise_message RuntimeError, /incorrectly formatted/ do
      rippage = @effect.rip('assert{ x == 42 ')
    end
  end

  def test_diagnostic_reflections
    x = 42

    assert_flunk /assert.*x == 43.*x\s+--> 42/m do
      assert{ x == 43 }
    end
  end

  def test_capture
    @effect.reflect << 'yo'

    @effect.capture do
      @effect.reflect << 'x'
    end

    assert_capture 'x', 42
  end

  def test_equality
    rippage = [:binary, 
                  [:var_ref, [:@ident, "x", [1, 0]]], 
                   :==, 
                   [:@int, "42", [1, 5]]
              ]
    @effect.sender rippage
    assert{ 'x == 42' == @effect.reflect }
    assert_capture 'x', 42
    assert_capture 'x == 42', true
  end

  def test_paren
   rippage = [[:binary,
          [:var_ref, [:@ident, "x", [1, 0]]],
          :==,
          [:paren, [[:binary, [:@int, "41", [1, 6]], :+, [:@int, "1", [1, 11]]]]]
        ]]
    assert{ rippage == @effect.rip('x == (41 + 1)') }
    @effect.sender rippage.last
    assert_equal 'x == (41 + 1)', @effect.reflect
    assert_capture 'x', 42
    assert_capture '41 + 1', 42
    assert_capture 'x == (41 + 1)', true
  end

  def test_int
    rippage = [ [:binary, 
                  [:var_ref, [:@ident, "x", [1, 0]]], 
                  :==, 
                  [:@int, "42", [1, 5]]
                 ] ]
    assert{ rippage == @effect.rip('x == 42') }
    @effect.sender [:@int, "42", [1, 5]]
    assert{ '42' == @effect.reflect }
  end

  def test_reflect
    rippage = [:@ident, "x", [1, 0]]
    @effect.sender rippage
    assert_equal 'x', @effect.reflect
    assert{ 'x' == @effect.reflect }
  end

  def test_multi_line_assertion    
    assert_flunk /false.*nil/m do
      assert do
        false
        42; nil
      end
    end
  end
  
  def test_rip
    assert{ @effect.rip('x == 42') == 
        [[:binary, 
           [:var_ref, [:@ident, "x", [1, 0]]], 
            :==, 
            [:@int, "42", [1, 5]]
          ]] }
  end

  def morgothrond(thumpwhistle)
    return false  #  what did you think such a function would do?? (-:
  end
  
  def test_morgothrond_thumpwhistle
    thumpwistle = 42
    
    x = assert_raise Test::Unit::AssertionFailedError do
      assert{ self.morgothrond(thumpwistle) }
    end
    
    assert{ x.message =~ /thumpwistle\s+--> 42/ }
    denigh{ x.message =~ /self.morgothrond\s+--> / }
  end

  def test_rip_broken_lines
    assert{ @effect.rip(["x ==\n", '42']) == 
                @effect.rip("x ==\n42") }
  end

  def test_rip_assertion_source
    @effect.rip(["x ==\n", '42'])
    assert{ @effect.assertion_source == "x ==\n42" }
  end
  
  def test_assert
    assert_flunk /x == 42.*false.*x \s*--> 43/m do
      x = 43
      assert{ x == 42 }
    end
  end

  def test_deny_everything
    assert_flunk /x.*true.*\s+--> 42/m do
      x = 42
      deny{ x == 42 }
    end
  end

  def test_assert_classic
    assert_flunk /false. is not true/ do
      assert false
    end
  end

  def test_assertion_diagnostics
    tattle = "doc says what's the condition?"
    
    assert_flunk /the condition.*tattle/m do
      x = 43
      assert(tattle){ x == 42 }
    end  #  ERGO document tattle

    assert_flunk /on a mission/m do
      x = 42
      deny("I'm a man that's on a mission"){ x == 42 }
    end
  end

end

