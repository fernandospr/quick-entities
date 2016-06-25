if ENV['MONGOHQ_URL']
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
else
  DB = Mongo::Connection.new.db("test")
end

def get_user_collection_names (user)
  collection_names = DB.collection_names.to_a
  filter_db_collection_names(collection_names)
  filter_non_user_collection_names(collection_names, user)
  rename_user_collection_names(collection_names, user)
  collection_names
end

def get_user_entities (user, entities, filters)
  entities = get_user_collection_name(entities, user)
  coll = DB.collection(entities)
  coll.find( filters, { fields: {_id:0} } ).to_a
end

def create_entity (coll, json)
  json['id'] = json['id'].to_s
  coll.save(json)
end

def find_by_id (coll, id)
  coll.find( {'id' => id.to_s}, { fields: {_id:0} } ).to_a[0]
end

def drop_collection_if_empty (coll)
  if (coll.count == 0)
    coll.drop
  end
end

def filter_db_collection_names (collection_names)
  collection_names.delete_if{ |collection_name| is_db_collection_name(collection_name) }
end

def is_db_collection_name (collection_name)
  collection_name.strip.start_with?("system.")
end

def filter_non_user_collection_names (collection_names, user)
  if (!user.to_s.empty?)
    collection_names.delete_if{ |collection_name| !is_user_collection_name_with_user(collection_name, user) }
  else 
    collection_names.delete_if{ |collection_name| is_user_collection_name(collection_name) }
  end
end

def rename_user_collection_names (collection_names, user)
  if (!user.to_s.empty?)
    collection_names.map! { |collection_name| collection_name.sub("user." + user + ".", "") }
  end
end

def is_user_collection_name (collection_name)
  collection_name.strip.start_with?("user.")
end

def is_user_collection_name_with_user (collection_name, user)
  collection_name.strip.start_with?("user." + user)
end

def get_user_collection_name (collection_name, user)
  if (!user.to_s.empty?)
    "user." + user + "." + collection_name
  else
    collection_name
  end
end