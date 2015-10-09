#!/usr/bin/ruby

require 'cgi'
require 'pathname'

CGI.new

print "Content-type: text/html\n\n"
print "<p>#{CGI.escapeHTML($!.inspect)}<p/>"
