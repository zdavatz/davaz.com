#!/usr/bin/env ruby
# States -- davaz.com -- 18.07.2005 -- mhuggler@ywesee.com

def require_r(dir, prefix)
	path = File.expand_path(dir)
	Dir.entries(path).sort.each { |file|
		if /^[a-z_]+\.rb$/.match(file)
			require([prefix, file].join('/'))
		elsif(!/^\./.match(file))
			dirpath = File.expand_path(file, path)
			new_prefix = [prefix, file].join('/')
			if (File.ftype(dirpath) == 'directory')
				require_r(dirpath, new_prefix)
			end
		end
	}
end

require_r(File.expand_path(File.dirname(__FILE__)), 'state')
