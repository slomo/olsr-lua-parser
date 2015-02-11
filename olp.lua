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

local Olp = {}

function Olp.parse(data)

   local buf = vstruct.cursor(data)
   local packet = Packet:new()

   vstruct.read("> length:u2 sequenceNumber:u2 ", buf, packet)

   if data:len() ~= packet.length then
      error("Invalid packet size")
   end

   while(buf:seek() < data:len()) do
      local message = {}
      vstruct.read([[> type:u1 vtime:u1 size:u2
                       originatorAddress:u4
                       timeToLive:u1 hopCount:u1 sequnceCounter:u2]], buf, message)
      message.offset = buf:seek()
      buf:seek('cur', message.size - 12)

      table.insert(packet.messages, message)
   end

   return packet
end

return Olp
