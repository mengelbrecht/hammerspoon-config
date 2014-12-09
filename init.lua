package.path = hs.configdir .. "/rocks/share/lua/5.2/?.lua;" ..
               hs.configdir .. "/rocks/share/lua/5.2/?/init.lua;" ..
               package.path
package.cpath = hs.configdir .. "/rocks/lib/lua/5.2/?.so;" .. package.cpath

require 'moonscript'
require 'main'
