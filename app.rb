require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'

DB = Mongo::Connection.new.db('fufodb');

get '/entities' do
  content_type :json

  coll = DB.collection('entities')
  coll.find( {}, { fields: {_id:0} } ).to_a.to_json
end

post '/entities' do
  coll = DB.collection('entities')
  json = JSON.parse(request.body.read)
  coll.save(json)
end

