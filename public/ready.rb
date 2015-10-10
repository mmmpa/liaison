#!/usr/bin/ruby

require 'pathname'
require(Pathname.new(__dir__) + "../app/app.rb")

print "Content-type: text/html\n\n<xmp>"
LiaisonApplication.build_database(LiaisonApplication.analysed_config)
print "</xmp>\n"