local dap = require('dap')

local function workspace()
  return vim.fs.root(0, function(name)
    return name == 'cabal.project' or name == 'stack.yaml' or name:match('%.cabal$') ~= nil
  end) or vim.fn.expand('%:p:h')
end

local entry_files = {}

local function entry_file()
  local root = workspace()
  local path = vim.fn.input('Haskell entry file: ', entry_files[root] or root .. '/Main.hs', 'file')
  if path == '' then
    return dap.ABORT
  end
  path = vim.fn.expand(path)
  if path:sub(1, 1) ~= '/' then
    path = root .. '/' .. path
  end
  path = vim.fs.normalize(path)
  if vim.fn.filereadable(path) ~= 1 then
    vim.notify('Haskell entry file not found: ' .. path, vim.log.levels.ERROR)
    return dap.ABORT
  end
  entry_files[root] = path
  return path
end

dap.adapters.ghc = {
  type = 'executable',
  command = 'haskell-debug-adapter',
}

dap.configurations.haskell = dap.configurations.haskell or {}
table.insert(dap.configurations.haskell, {
  type = 'ghc',
  request = 'launch',
  name = 'Debug Haskell entry file',
  workspace = workspace,
  startup = entry_file,
  startupFunc = '', -- Defaults to main.
  startupArgs = '',
  mainArgs = '',
  stopOnEntry = false,
  ghciCmd = function()
    local root = workspace()
    local command = 'ghci-dap --interactive'
    if vim.fn.filereadable(root .. '/stack.yaml') == 1 then
      command = 'stack exec -- ' .. command
    elseif vim.fn.filereadable(root .. '/cabal.project') == 1
      or #vim.fn.glob(root .. '/*.cabal', false, true) > 0 then
      command = 'cabal exec -- ' .. command
    end
    return command
  end,
  ghciEnv = vim.empty_dict(),
  ghciPrompt = 'λ: ',
  ghciInitialPrompt = 'ghci> ',
  logFile = vim.fn.stdpath('cache') .. '/haskell-dap.log',
  logLevel = 'Warning',
  forceInspect = false,
})
