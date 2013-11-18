local md5 = require('md5')
local lfs = require('lfs')
local JSON = require('JSON')

local URL = ""
if arg[1] == '--url' then
	URL = arg[2]
end

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
	local f = io.open(filename, 'rt')
	local t = f:read('*a')
	f:close()
	return t
end

local function writefile(filename, txt)
	local f = io.open(filename, 'wt')
	local t = f:write(txt)
	f:close()
end

local function basename(filename)
	return filename:gsub('.*([\\/]+)$', '%1')
end


local all = matchfiles('.', '.*%.mpq')

local files = {}

print('Files to release:')
for i,v in ipairs(all) do
	local base = basename(v)
	local f = {
		name = base,
		size = lfs.attributes(v, 'size'),
		hash = md5.sumhexa(readfile(v)),
	}
	if #URL > 0 then
		f.url = URL..base
	end
	print(f.name, f.size, f.hash)

	files[#files+1] = f
end

print('')

local version = JSON:decode(readfile('v'))
version.files = files
local v = ''
repeat
	if #v > 0 then
		print(string.format('Bad version format: %s, retry.', v))
	end
	io.write(string.format('Current version is %s, input a new version ([Enter] to skip):', version.version))
	v = io.read('*l')
until #v == 0 or (v:match('^%d+.%d+.%d+$'))

if #v > 0 then version.version = v end

local encoded = JSON:encode_pretty(version)
writefile('v', encoded)
