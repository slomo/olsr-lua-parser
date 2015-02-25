TupleStore = {}

function TupleStore:new(keys, o)
   o = o or {}
   o.keys = keys
   o.data = o.data or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

function TupleStore:lookup(keys)
   if #keys ~= #self.keys then
      error("Wrong amount of keys provided")
   end

   local data = self.data
   for index, key in pairs(keys) do
      if data[key] ~= nil then
         data = data[key]
      else
         return nil
      end
   end
   return data
end

function TupleStore:set(keys, value)
   if #keys ~= #self.keys then
      error("Wrong amount of keys provided")
   end

   local data = self.data
   for index, key in pairs(keys) do
      if data[key] == nil and index < #keys then
         data[key] = {}
      elseif index == #keys then
         data[key] = value
         break;
      end
      data = data[key]
   end
end

return TupleStore
