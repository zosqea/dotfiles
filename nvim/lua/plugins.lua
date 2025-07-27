-- lua/plugins.lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- UI Enhancement
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons' },

  -- Essential Tools
  { 'nvim-tree/nvim-tree.lua', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

  -- Rust Development Suite
  {
    'simrat39/rust-tools.nvim',
    ft = 'rust',  -- Load only for Rust files
    dependencies = {
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',  -- Debug Adapter Protocol
      'nvim-lua/plenary.nvim'
    },
    config = function()
      local rt = require('rust-tools')
      rt.setup({
        server = {
          on_attach = function(_, bufnr)
            -- Rust-specific keymaps
            vim.keymap.set('n', '<leader>rr', rt.runnables.runnables, { buffer = bufnr })
            vim.keymap.set('n', '<leader>rd', rt.debuggables.debuggables, { buffer = bufnr })
            vim.keymap.set('n', '<leader>rc', rt.crate_graph.view_crate_graph, { buffer = bufnr })
          end,
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = {
                command = 'clippy',
                extraArgs = { '--no-deps' }
              },
              procMacro = { enable = true },
              cargo = { features = 'all' }
            }
          }
        },
        tools = {
          inlay_hints = {
            auto = true,
            show_parameter_hints = true
          }
        }
      })
    end
  },

  -- Core LSP & Autocompletion
  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local lsp = require('lsp-zero')
      lsp.preset('recommended')

      lsp.ensure_installed({
        'rust_analyzer',
        'tsserver',
        'pyright',
        'lua_ls',
        'gopls',
        'clangd'
      })

      lsp.on_attach(function(_, bufnr)
        lsp.default_keymaps({ buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, { buffer = bufnr })
      end)

      -- Configure autocompletion
      local cmp = require('cmp')
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        }),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })

      lsp.setup()

      -- Language-specific setups
      require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
      require('lspconfig').rust_analyzer.setup({}) -- Handled by rust-tools
    end
  },

  -- Additional Productivity
  { 'tpope/vim-fugitive' },          -- Git integration
  { 'lewis6991/gitsigns.nvim' },     -- Git line decorations
  { 'windwp/nvim-autopairs' },       -- Auto-close brackets
  { 'numToStr/Comment.nvim' },       -- Smart comments
  { 'lukas-reineke/indent-blankline.nvim' }  -- Indentation guides
})

-- Post-plugin configuration
require('gitsigns').setup()
require('nvim-autopairs').setup()
require('Comment').setup()
require('indent_blankline').setup({
  show_current_context = true,
  show_current_context_start = true,
})
