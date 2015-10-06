#!/usr/bin/ruby

require 'cgi'

def error_cgi
  print "<p>#{CGI.escapeHTML($!.inspect)}<p/>"
end

begin
  require '../app/configuration.rb'
  execute
rescue
  error_cgi
end
