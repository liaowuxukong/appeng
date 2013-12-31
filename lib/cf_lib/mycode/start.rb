#!/usr/bin/env ruby
# vim: ft=ruby
libdir = File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "rubygems"

$base_path='/home/lucas/coding/ruby/cf-5.4.4/lib'
require "#{$base_path}/cf"
require "#{$base_path}/cf/plugin"

$stdout.sync = true

CF::Plugin.load_all
if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new("1.9.3")
  warn "ERROR: \033[31mRuby version #{RUBY_VERSION} is not supported.\033[0m Please install 1.9.3 or later. (See http://docs.cloudfoundry.com/docs/common/install_ruby.html for more information)"
  exit 1
end

# 直接调用的mothership的start
CF::CLI.start(ARGV)
