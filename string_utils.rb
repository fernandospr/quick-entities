def is_number? (string)
  true if Float(string) rescue false
end

def is_boolean? (string)
  "true".eql?(string) || "false".eql?(string)
end

def to_boolean (string)
    string == 'true'
end