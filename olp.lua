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
   self.__index = self
   return o
end

local Message = {}
function Message:__tostring()
   return "message{type = " .. tostring(self.type) .. ", originator = " .. tostring(self.sequenceNumber) .. "}"
end

function Message:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

local Olp = {
   inet_proto = 6;
   address_length = 16;
   message_header_size = 24;
   minimal_packet_length = 16;
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


--- Parse an olsr packet and the basic message structures.
-- Takes the raw data string of an olsr udp package and parse the package and message header. The
-- packet length is validate against the sum of the message sizes and the length of the raw data
-- string given.
-- @param data Olsr upd packet content
function Olp:parse(data)
   local buf = vstruct.cursor(data)
   local packet = Packet:new()

   vstruct.read("> length:u2 sequenceNumber:u2 ", buf, packet)

   if data:len() ~= packet.length then
      error("Packet length must match udp content length")
   end

   if packet.length < self.minimal_packet_length then
      error("Packet must be bigger than minimal_packet_length")
   end

   while(buf:seek() < data:len()) do
      local message = {}
      vstruct.read([[> type:u1 vtime:u1 size:u2
                       originatorAddress:u]] .. self.address_length .. [[
                       timeToLive:u1 hopCount:u1 sequnceCounter:u2]], buf, message)
      message.offset = buf:seek()

      if message.offset + message.size - self.message_header_size > data:len() then
         error("Message length should not exeede packet boundary")
      end

      buf:seek('cur', message.size - self.message_header_size)
      table.insert(packet.messages, message)
   end

   if #packet.messages == 0 then
      error ("Packet should contain contain at least one message")
   end

   for key, message in pairs(packet.messages) do
      buf:seek('set', message.offset)
      message.data = buf:read(message.size - self.message_header_size)
   end
   return packet
end



function Olp:tagForRouting(message)

   if message.timeToLive <= 0 then
   end
end

function Olp:tagForProcessing(message)


end


return Olp
