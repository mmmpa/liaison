#!/usr/bin/ruby

require 'cgi'
require 'pathname'

begin
  require(Pathname.new(__dir__) + "../app/configuration.rb")
  execute
rescue
  print "Content-type: text/html\n\n"
  print "<p>#{CGI.escapeHTML($!.inspect)}<p/>"
end
