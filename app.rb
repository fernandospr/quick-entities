require 'bundler'
require 'securerandom'
Bundler.require

get '/' do 
  content_type :json

  collection_names = DB.collection_names.to_a
  delete_db_collection_names(collection_names)
  collection_names.to_json
end

get '/:entities' do |entities|
  content_type :json

  coll = DB.collection(entities)
  coll.find( get_filters(request), { 'projection' => { '_id': 0 } } ).to_a.to_json
end

post '/:entities' do |entities|
  content_type :json

  halt_if_invalid_entities_name(entities)

  coll = DB.collection(entities)
  json = JSON.parse(request.body.read)

  if !json['id']
    json['id'] = SecureRandom.uuid
  end
  halt_if_id_is_missing(json)
  halt_if_exists(coll, json['id'])
  
  create_entity(coll, json)
  
  find_by_id_or_halt(coll, json['id']).to_json
end

put '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  json = JSON.parse(request.body.read)

  find_by_id_or_halt(coll, id)

  halt_if_trying_to_update_to_a_new_id_that_exists(coll, id, json['id'])

  coll.find({'id' => id}).delete_one
  create_entity(coll, json)
  
  find_by_id_or_halt(coll, id).to_json
end

patch '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  json = JSON.parse(request.body.read)

  find_by_id_or_halt(coll, id)

  halt_if_trying_to_update_to_a_new_id_that_exists(coll, id, json['id'])

  coll.update_one({'id' => id.to_s}, '$set' => json)

  find_by_id_or_halt(coll, id).to_json
end

get '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  find_by_id_or_halt(coll, id).to_json
end

delete '/:entities/:id' do |entities,id|
  content_type :json

  coll = DB.collection(entities)
  find_by_id_or_halt(coll, id)

	coll.find({'id' => id}).delete_one

  drop_collection_if_empty(coll)

  halt 204
end

require_relative 'db'
require_relative 'string_utils'
require_relative 'routing_helper'