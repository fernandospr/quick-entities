require 'bundler'
Bundler.require

if ENV['MONGOHQ_URL']
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
else
  DB = Mongo::Connection.new.db("fufodb")
end

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

