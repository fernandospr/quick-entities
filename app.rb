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

  user_entities = get_user_entities(header_token, entities, get_filters(request))
  user_entities.to_json
end

post '/:entities' do |entities|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  halt_if_invalid_entities_name(entities)

  json = JSON.parse(request.body.read)
  sanitize_id_or_generate_if_missing(json)

  coll = get_user_collection(header_token, entities)

  halt_if_exists(coll, json['id'])
  
  create_entity(coll, json)
  
  user_entities = find_by_id_or_halt(coll, json['id'])
  user_entities.to_json
end

put '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  json = JSON.parse(request.body.read)
  sanitize_id(json)

  coll = get_user_collection(header_token, entities)

  find_by_id_or_halt(coll, id)

  halt_if_trying_to_update_to_a_new_id_that_exists(coll, id, json['id'])

  put_by_id(coll, id, json)
  
  if (json['id'])
    id = json['id']
  end
  user_entity = find_by_id_or_halt(coll, id)
  user_entity.to_json
end

patch '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  json = JSON.parse(request.body.read)
  sanitize_id(json)

  coll = get_user_collection(header_token, entities)

  find_by_id_or_halt(coll, id)

  halt_if_trying_to_update_to_a_new_id_that_exists(coll, id, json['id'])

  patch_by_id(coll, id, json)

  if (json['id'])
    id = json['id']
  end
  user_entity = find_by_id_or_halt(coll, id)
  user_entity.to_json
end

get '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  coll = get_user_collection(header_token, entities)

  user_entity = find_by_id_or_halt(coll, id)
  user_entity.to_json
end

delete '/:entities/:id' do |entities,id|
  content_type :json
  header_token = request.env["HTTP_X_API_KEY"]

  coll = get_user_collection(header_token, entities)

  find_by_id_or_halt(coll, id)

	delete_by_id(coll, id)

  halt 204
end

require_relative 'db'
require_relative 'string_utils'
require_relative 'routing_helper'