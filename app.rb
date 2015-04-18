require 'bundler'
Bundler.require

if ENV['MONGOHQ_URL']
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
else
  DB = Mongo::Connection.new.db("test")
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

  halt_if_id_is_missing(json)
  halt_if_exists(coll, json['id'])
  
  create_entity(coll, json)
  halt 204 
end

put '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  json = JSON.parse(request.body.read)

  find_by_id_or_halt(coll, id)

  coll.remove({'id' => id})

  create_entity(coll, json)
  halt 204 
end

get '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  entity = find_by_id_or_halt(coll, id)

  entity.to_json
end

delete '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  find_by_id_or_halt(coll, id)

	coll.remove({'id' => id})

  if (coll.count == 0)
    coll.drop
  end

  halt 204
end

def create_entity (coll,json)
  json['id'] = json['id'].to_s
  coll.save(json)
end

def halt_if_id_is_missing (json)
  if !json['id']
    halt 400, { :id => "id_required", :message => "The id is required" }.to_json
  end
end

def halt_if_exists (coll, id)
  if find_by_id(coll,id)
    halt 400, { :id => "id_already_exists", :message => "An entity with id " + id.to_s + " already exists" }.to_json
  end
end

def find_by_id_or_halt (coll, id)
  entity = find_by_id(coll, id)
  if !entity
    halt 404
  end
  entity
end

def find_by_id (coll, id)
  coll.find( {'id' => id.to_s}, { fields: {_id:0} } ).to_a[0]
end
