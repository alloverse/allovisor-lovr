print("Booting menuserv")

lovr = require 'lovr'
lovr.filesystem, lovr.thread = require 'lovr.filesystem', require 'lovr.thread'
local json = require("json")
local util = require "util"
local allonet = util.load_allonet()

allosocket = allonet.start_standalone_server(21338)
assert(allosocket ~= -1)
print("Menuserv started")

local running = true
local chan = lovr.thread.getChannel("menuserv")
chan:push("booted", 2.0)
while running do
  local ok = allonet.poll_standalone_server(allosocket)
  assert(ok, "standalone server failed")
  local m = chan:pop()
  if m == "exit" then running = false end
end
print("menu server shutting down", allonet)

