#!/usr/bin/lua
-------------------------------------------------------------
-- NOTE: each wrk thread has an independent Lua scripting
-- context and thus there will be one counter per thread

counter = 0
paths_to_visit = {"/de/page/feedback", "/de/page/about", "/", '/en/works/movies'}
request = function()
   counter = counter + 1
   return wrk.format(nil,  paths_to_visit[(counter % table.getn(paths_to_visit))+ 1])
end

