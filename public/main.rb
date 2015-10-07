#!/usr/bin/ruby

require 'cgi'

begin
  require '../app/configuration.rb'
  execute
rescue
  print "<p>#{CGI.escapeHTML($!.inspect)}<p/>"
end
