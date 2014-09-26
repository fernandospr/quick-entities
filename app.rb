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
  content_type :json

  coll = DB.collection('entities')
  json = JSON.parse(request.body.read)
  coll.save(json)

  halt 204
end

get '/entities/:id' do |id|
  content_type :json

  coll = DB.collection('entities')
  entity = coll.find( {'id' => id}, { fields: {_id:0} } ).to_a[0]
  if entity
  	entity.to_json
  else
  	halt 404
  end
end

delete '/entities/:id' do |id|
  content_type :json
  
  coll = DB.collection('entities')
  entity = coll.find( {'id' => id}, { fields: {_id:0} } ).to_a[0]
  if entity
	coll.remove({'id' => id})
  	halt 204
  else
  	halt 404
  end
end
