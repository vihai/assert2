#  this is assert{ 2.1 }, the Ruby 1.9+ rewrite of assert{ 2.0 }, using Ripper
#   note we only work with Ruby >= 1.9 !

#~ if RUBY_VERSION < '1.9.0'
  #~ puts "\nWarning: This version of assert{ 2.0 } only works\n" +
       #~ "with Ripper, which requires a Ruby version >= 1.9\n\n"
#~ end
#  FIXME  the first failing assertion of a batch should suggest you get with Ruby1.9...

require 'assert2/common/assert2_utilities'

#  TODO  install Coulor
#  TODO  add :verbose => option to assert{}
#  TODO  pay for Staff Benda Bilili  ALBUM: Tr�s Tr�s Fort (Promo Sampler) !

module Test; module Unit; module Assertions

  def colorize(whatever)
    # FIXME stop ignoring this and start colorizing v2.1!
  end

end; end; end

require '../test/assert2_suite.rb' if $0 == __FILE__ and File.exist?('../test/assert2_suite.rb')
#require 'ripdoc_suite.rb' if $0 == __FILE__ and File.exist?('ripdoc_suite.rb')

class File
  def self.write(filename, contents)
    open(filename, 'w'){|f|  f.write(contents)  }
  end
end
