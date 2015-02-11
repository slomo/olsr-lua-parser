local vstruct = require('vstruct');

local Packet = {}
function Packet:__tostring()
   return "packet{length = " .. tostring(self.length) .. ", sequnceNumber = " .. tostring(self.sequenceNumber) .. "}"
end

function Packet:new(o)
   o = o or {}
   o.messages = o.messages or {}
   o.length = o.length or 0
   o.sequenceNumber = o.sequence or 0
   setmetatable(o, self)
   return o
end

local Message = {}
function Message:__tostring()
   return "message{type = " .. tostring(self.type) .. ", originator = " .. tostring(self.sequenceNumber) .. "}"
end

function Message:new(o)
   o = o or {}
   setmetatable(o, self)
   return o
end

local Olp = {
   inet_proto = 6;
   address_length = 16;
   message_header_size = 24;
}


function Olp:setProto(inet_proto)
   self.inet_proto = inet_proto or 6
   if self.inet_proto == 6 then
      self.address_length = 16
   else
      self.address_length = 4
   end
   self.message_header_size = self.address_length + 8
end

function Olp:parse(data)
   local buf = vstruct.cursor(data)
   local packet = Packet:new()

   vstruct.read("> length:u2 sequenceNumber:u2 ", buf, packet)

   if data:len() ~= packet.length then
      error("Invalid packet size")
   end

   while(buf:seek() < data:len()) do
      local message = {}
      vstruct.read([[> type:u1 vtime:u1 size:u2
                       originatorAddress:u]] .. self.address_length .. [[
                       timeToLive:u1 hopCount:u1 sequnceCounter:u2]], buf, message)
      message.offset = buf:seek()

      if message.offset + message.size - self.message_header_size > data:len() then
         error("Invalid message size")
      end

      buf:seek('cur', message.size - self.message_header_size)
      table.insert(packet.messages, message)
   end

   for key, message in pairs(packet.messages) do
      buf:seek('set', message.offset)
      message.data = buf:read(message.size - self.message_header_size)
   end
   return packet
end

return Olp
