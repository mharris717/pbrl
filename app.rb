require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + "/load"

get "/" do
  haml :all
end