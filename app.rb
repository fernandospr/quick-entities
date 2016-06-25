require 'bundler'
require 'securerandom'
Bundler.require

get '/' do 
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  collection_names = get_user_collection_names(header_token)
  collection_names.to_json
end

get '/:entities' do |entities|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  entities = get_user_entities(header_token, entities, get_filters(request))
  entities.to_json
end

post '/:entities' do |entities|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  halt_if_invalid_entities_name(entities)

  json = JSON.parse(request.body.read)
  # TODO: Refactor id check
  if !json['id']
    json['id'] = SecureRandom.uuid
  end
  halt_if_id_is_missing(json)

  coll = get_user_collection(header_token, entities)
  halt_if_exists(coll, json['id'])
  
  create_entity(coll, json)
  
  entities = find_by_id_or_halt(coll, json['id'])
  entities.to_json
end

put '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  json = JSON.parse(request.body.read)
  coll = get_user_collection(header_token, entities)

  find_by_id_or_halt(coll, id)

  halt_if_trying_to_update_to_a_new_id_that_exists(coll, id, json['id'])

  coll.remove({'id' => id})
  create_entity(coll, json)
  
  entity = find_by_id_or_halt(coll, id)
  entity.to_json
end

patch '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  json = JSON.parse(request.body.read)
  coll = get_user_collection(header_token, entities)

  find_by_id_or_halt(coll, id)

  halt_if_trying_to_update_to_a_new_id_that_exists(coll, id, json['id'])

  coll.update({'id' => id.to_s}, '$set' => json)

  entity = find_by_id_or_halt(coll, id)
  entity.to_json
end

get '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  coll = get_user_collection(header_token, entities)
  entity = find_by_id_or_halt(coll, id)
  entity.to_json
end

delete '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  coll = get_user_collection(header_token, entities)
  find_by_id_or_halt(coll, id)

	coll.remove({'id' => id})

  drop_collection_if_empty(coll)

  halt 204
end

require_relative 'db'
require_relative 'string_utils'
require_relative 'routing_helper'