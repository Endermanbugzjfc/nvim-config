return {
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  ft = "rust",
  config = function()
    vim.g.rustaceanvim = function()
      -- https://github.com/williamboman/mason.nvim/discussions/33#discussioncomment-6067481
      local mason_registry = require('mason-registry')
      local codelldb = mason_registry.get_package("codelldb") -- note that this will error if you provide a non-existent package name
      codelldb:get_install_path() -- returns a string like "/home/user/.local/share/nvim/mason/packages/codelldb"
      local extension_path = codelldb:get_install_path() .. "/extension/"

      -- https://github.com/mrcjkb/rustaceanvim?tab=readme-ov-file#zap-quick-setup
      local codelldb_path = extension_path .. 'adapter/codelldb'
      local liblldb_path = extension_path .. 'lldb/lib/liblldb'
      local this_os = vim.uv.os_uname().sysname;

      -- The path is different on Windows
      if this_os:find "Windows" then
        codelldb_path = extension_path .. "adapter\\codelldb.exe"
        liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
      else
        -- The liblldb extension is .so for Linux and .dylib for MacOS
        liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
      end

      local cfg = require('rustaceanvim.config')
      return {
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      }
    end
  end
}
