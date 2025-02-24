local Object = {}
Object.__index = Object
Object.__super = nil
Object.__name = "Object"
Object.__type = "Class"

local class_list = {[Object.__name] = Object}
local format = string.format
local gsub = string.gsub
local counter = 0


--- Class-creating function ---
local function class(class_name, super, ...)
  if type(super) ~= "table" then
    super = assert(class_list[super or "Object"], format("Class %q doesn't exist.", super))
  end
  class_name = class_name or super.__name .. "(extension)"
  assert(class_name:gsub("%.", "") == class_name, "Can't have dots in class_name.")
  
  local new_class = {}
  for k, v in pairs(super) do
    if k:find("__") == 1 then
      new_class[k] = v
    end
  end

  new_class.__name = class_name
  new_class.__type = "Class"
  new_class.__super = super
  new_class.__index = new_class
  setmetatable(new_class, super)

  new_class:implement(...)
  class_list[new_class:__full_name()] = new_class

  return new_class
end


local function get_class(full_class_name)
  return class_list[full_class_name]
end


local function instantiate(class_name, ...)
  assert(class_list[class_name], format("Class %q doesn't exist.", class_name))
  return class_list[class_name](...)
end


--- CREATING BASE CLASS "OBJECT" ---
function Object:init()
end


function Object:implement(...)
  local list = {...}
  for i = 1, #list do
    local class = list[i]
    if type(class) == "string" then class = get_class(class); end
    
    for k,v in pairs(class) do
      self[k] = v
    end
  end
end


function Object:is(class)
  local c = self.__class or self
  if type(class) == "string" then class = get_class(class); end
  
  while c ~= nil do
    if c == class then
      return true
    end
    c = c.__super
  end
  
  return false
end


function Object:__call(...)
  local obj = setmetatable({__type = "Object", __class = self, __id = tostring(counter)}, self)
  obj:init(...)
  counter = counter + 1
  return obj
end


function Object:__full_name()
  local name = self.__name
  local super = self.__super
  while super ~= Object do
    name = super.__name .. "." .. name
    super = super.__super
  end
  return name
end


return {class=class, instantiate=instantiate, get_class}
