def get_filters (request)
  filters = Hash.new
  request.GET.each do |k,v| 
    if is_number?(v)
      orlist = Array.new
      orlist.push({k => v.to_f})
      orlist.push({k => v})
      filters.store("$or", orlist)
    elsif is_boolean?(v)
      orlist = Array.new
      orlist.push({k => to_boolean(v)})
      orlist.push({k => v})
      filters.store("$or", orlist)
    else
      filters.store(k, v)
    end
  end
  filters
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

def halt_if_trying_to_update_to_a_new_id_that_exists (coll, current_id, new_id)
  if (new_id && current_id.to_s != new_id.to_s)
    halt_if_exists(coll, new_id.to_s)
  end
end

def find_by_id_or_halt (coll, id)
  entity = find_by_id(coll, id)
  if !entity
    halt 404
  end
  entity
end

def halt_if_invalid_entities_name (entities)
  if is_db_collection_name(entities)
    halt 400, { :id => "invalid_entities_name", :message => "Cannot create entities with the name " + entities }.to_json
  end
end