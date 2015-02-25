require('luaunit')

TestOlsrPackageParsing = {}
function TestOlsrPackageParsing:testSimpleIpv6Packet()
   local olp = require('olp')
   local example_data = string.char(0x00, 0x1C, 0x00, 0x01,
                                    -- message 1
                                    0x23, 0x01, 0x00, 0x18,
                                    -- ipv6 2001:db8:85a3::8a2e:370:7334
                                    0x20, 0x01, 0x0d, 0xb8,
                                    0x85, 0xa3, 0x8a, 0x2e,
                                    0x03, 0x70, 0x73, 0x34,
                                    -- end ipv6
                                    0x01, 0x01, 0x01, 0x00,
                                    0x42, 0x43, 0x44, 0x45)

   local olsr_package = olp:parse(example_data)

   assertEquals(olsr_package.length, 0x1C)
   assertEquals(olsr_package.sequenceNumber, 0x01)
   assertEquals(#olsr_package.messages, 1)

   assertEquals(olsr_package.messages[1].type, 0x23)
   assertEquals(olsr_package.messages[1].vtime, 0x01)
   assertEquals(olsr_package.messages[1].size, 0x18)
end

function TestOlsrPackageParsing:testSimplePacket()
   local olp = require('olp')
   olp:setProto(4)
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

   local olsr_package = olp:parse(example_data)

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


function TestOlsrPackageParsing:testInvalidPacketSize()
   local olp = require('olp')
   olp:setProto(4)
   local to_long_package = string.char(0x00, 0x24, 0x00, 0x01,
                                       -- message
                                       0x23, 0x01, 0x00, 0x10,
                                       192,   168,    0,    1,
                                       0x01, 0x01, 0x01, 0x00,
                                       0x42, 0x43, 0x44, 0x45,
                                       -- additional data
                                       0x01)

   assertError("Invalid packet size",
               olp.parse, olp,
               to_long_package)

   local to_short_package = string.char(0x00, 0x24, 0x00, 0x01,
                                        -- message to short
                                        0x23, 0x01, 0x00, 0x10,
                                        192,   168,    0,    1,
                                        0x01, 0x01, 0x01, 0x00,
                                        0x42, 0x43, 0x44)

   assertError("Invalid message size",
               olp.parse, olp,
               to_short_package)
end

TestTupleStore = {}
function TestTupleStore:testStoreAndLookup()
   local tupleStore = require('tupleStore')
   local store = tupleStore:new({'keyA', 'keyB', 'keyC'})

   store:set({'a', 'b', 'c'}, 11)
   assertEquals(store:lookup({'a', 'b', 'c'}), 11)
end

function TestTupleStore:testParameterValidation()
   local tupleStore = require('tupleStore')
   local store = tupleStore:new({'keyA', 'keyB', 'keyC'})

   assertError("Wrong amount of keys provided",
               store.set, store,
               {'a', 'b'}, 11)

   assertError("Wrong amount of keys provided",
               store.set, store,
               {'a', 'b', 'c', 'd'}, 11)

   assertError("Wrong amount of keys provided",
               store.lookup, store,
               {'a', 'b'})

   assertError("Wrong amount of keys provided",
               store.lookup, store,
               {'a', 'b', 'c', 'd'})
end

LuaUnit:run()
