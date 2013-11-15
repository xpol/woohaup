local md5 = require('md5')
local lfs = require('lfs')
local JSON = require('JSON')

function matchfiles(path, pattern, files)
	files = files or {}
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local f = path..'/'..file
            local mode = lfs.attributes (f, 'mode')
    		if mode == 'file' then
    			if string.match(file, pattern) then
        			files[#files+1] = file
        		end
    		end
        end
    end
    return files
end

local function readfile(filename)
	local f = io.open(filename, 'rb')
	local t = f:read('*a')
	f:close()
	return t
end

local function writefile(filename, txt)
	local f = io.open(filename, 'wb')
	local t = f:write(txt)
	f:close()
end

local function basename(filename)
	return filename:gsub('.*([\\/]+)$', '%1')
end


local all = matchfiles('.', '.*%.mpq')

local files = {}


for i,v in ipairs(all) do
	print(v)
	local base = basename(v)
	local f = {
		name = base,
		size = lfs.attributes(v, 'size'),
		hash = md5.sumhexa(readfile(v)),
		url = "https://raw.github.com/xpol/woohaup/master/"..base
	}
	files[#files+1] = f
end


local version = JSON:decode(readfile('version.json'))
version.files = files
local encoded = JSON:encode_pretty(version)
writefile('version.json', encoded)
