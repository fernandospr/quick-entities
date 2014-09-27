require 'bundler'
Bundler.require

if ENV['MONGOHQ_URL']
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
else
  DB = Mongo::Connection.new.db("fufodb")
end

get '/' do 
  content_type :json

  DB.collection_names.to_a.to_json
end

get '/:entities' do |entities|
  content_type :json

  coll = DB.collection(entities)
  coll.find( {}, { fields: {_id:0} } ).to_a.to_json
end

post '/:entities' do |entities|
  content_type :json

  coll = DB.collection(entities)
  json = JSON.parse(request.body.read)

  if !json['id']
  	halt 400, { :errors => "id required" }.to_json
  end

  entity = find_by_id(coll, json['id'])
  if !entity
  	coll.save(json)
  	halt 204
  else
  	halt 400, { :errors => "id already exists" }.to_json
  end
end

get '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  entity = find_by_id(coll, id)
  if entity
  	entity.to_json
  else
  	halt 404
  end
end

delete '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  entity = find_by_id(coll, id)
  if entity
	coll.remove({'id' => id})
  	halt 204
  else
  	halt 404
  end
end

def 

def find_by_id (coll, id)
  coll.find( {'id' => id}, { fields: {_id:0} } ).to_a[0]
end
