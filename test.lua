require('luaunit')

TestOlsrPackageParsing = {}
function TestOlsrPackageParsing:testSimplePacket()

   local olp = require('olp');

   local example_data = string.char(0x00, 0x24, 0x00, 0x01,
                                    -- message 1
                                    0x23, 0x01, 0x00, 0x10,
                                    192,   168,    0,    1,
                                    0x01, 0x01, 0x01, 0x00,
                                    0x42, 0x43, 0x44, 0x45,
                                    -- message 2
                                    0x46, 0x01, 0x00, 0x10,
                                    192,   168,    1,    1,
                                    0x01, 0x01, 0x01, 0x00,
                                    0x02, 0x03, 0x04, 0x05)



   local olsr_package = olp.parse(example_data)

   assertEquals(olsr_package.length, 0x24)
   assertEquals(olsr_package.sequenceNumber, 0x01)
   assertEquals(#olsr_package.messages, 2)

   assertEquals(olsr_package.messages[1].type, 0x23)
   assertEquals(olsr_package.messages[1].vtime, 0x01)
   assertEquals(olsr_package.messages[1].size, 0x10)

   assertEquals(olsr_package.messages[2].type, 0x46)
   assertEquals(olsr_package.messages[2].vtime, 0x01)
   assertEquals(olsr_package.messages[2].size, 0x10)
end

LuaUnit:run()
