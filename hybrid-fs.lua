exports.name = "creationix/hybrid-fs"
exports.version = "0.1.0"
exports.dependencies = {
  "creationix/coro-fs",
}

local makeChroot = require('coro-fs').chroot
local pathJoin = require('luvi').path.join
local bundle = require('luvi').bundle

return function (root)
  local match = root:match("^bundle:/?(.*)$")
  if not match then return makeChroot(root) end
  root = match

  local fs = {}
  function fs.scandir(path)
    path = pathJoin(root, './' .. path)
    local names = bundle.readdir(path)
    local i = 0
    return function ()
      i = i + 1
      local name = names[i]
      if not name then return end
      local stat = bundle.stat(pathJoin(path, name))
      stat.name = name
      return stat
    end
  end

  function fs.readFile(path)
    path = pathJoin(root, './' .. path)
    return bundle.readfile(path)
  end

  function fs.stat(path)
    path = pathJoin(root, './' .. path)
    return bundle.stat(path)
  end

  return fs
end
