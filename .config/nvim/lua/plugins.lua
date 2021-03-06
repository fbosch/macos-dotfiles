-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  end
  return
end

if packer_bootstrap and status_ok then
  packer.sync()
end

-- Have packer use a popup window
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
  },
})

local developmentFiles = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "lua", "markdown" }
local pluginGroup = vim.api.nvim_create_augroup("plugins", {})
local function lazy(plugin)
  return {
    plugin,
    event = "VimEnter",
    ft = developmentFiles,
  }
end

-- install packages
return packer.startup({
  function(use)
    use({
      "tweekmonster/startuptime.vim",
      "wbthomason/packer.nvim",
      "lewis6991/impatient.nvim",
      "luukvbaal/stabilize.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nathom/filetype.nvim",
      "travonted/luajob",
      lazy("dinhhuy258/git.nvim"),
      {
        "rcarriga/nvim-notify",
        ft = developmentFiles,
        event = "VimEnter",
        config = function()
          vim.schedule(require("configs.notify"))
        end
      },
      {
        "mbbill/undotree",
        event = "VimEnter",
        config = function()
          vim.g.undotree_WindowLayout = 2
        end
      },
      {
        "rmagatti/auto-session",
        event = "VimEnter",
        config = function()
          require("auto-session").setup({
            auto_session_root_dir = vim.fn.expand('~/.config')..'/nvim/.sessions//',
            log_level = "error",
          })
        end
      },
      {
       "romgrk/barbar.nvim",
        after = { "zenbones.nvim" },
        requires = { "kyazdani42/nvim-web-devicons" },
        config = function()
          require("bufferline").setup({
            animation = false,
            icon_pinned = "???",
            auto_hide = true,
          })
        end
      },
      {
        "fedepujol/move.nvim",
        ft = developmentFiles,
        event = "VimEnter",
     },
      {
        "echasnovski/mini.nvim",
        event = "CursorHold",
        config = function()
          vim.schedule(function()
            require("mini.trailspace").setup({
              only_in_normal_buffers = true
            })
          end)
        end
      },
      {
        "mcchrish/zenbones.nvim",
        requires = { lazy("rktjmp/lush.nvim") },
        event = "VimEnter",
        config = function()
          vim.cmd("colorscheme zenwritten")
          vim.schedule(require("configs.colorscheme"))
        end
      },
      {
        "github/copilot.vim",
        event = "CursorHoldI",
        ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      {
        "phaazon/hop.nvim",
        event = "CursorHold",
        ft = developmentFiles,
        config = function()
          vim.schedule(function()
            require("hop").setup({
              keys = "etovxqpdygfblzhckisuran"
            })
          end)
        end
      },
      {
        "folke/which-key.nvim",
        after = { "zenbones.nvim" },
        event = "VimEnter",
        config = function()
          vim.schedule(function()
            require("which-key").setup({
              window = {
                border = "rounded"
              }
            })
          end)
        end,
      },
      {
        "tpope/vim-commentary",
        event = "CursorHold",
        ft = developmentFiles
      },
      {
        "tpope/vim-surround",
        ft = developmentFiles,
        event = "InsertEnter",
      },
      {
        "lukas-reineke/indent-blankline.nvim",
        event = "CursorHold",
      },
      {
        "danilamihailov/beacon.nvim",
        event = "VimEnter",
        config = function()
          vim.g.beacon_enable = 0
          vim.defer_fn(function()
            vim.schedule(function()
              vim.g.beacon_ignore_filetypes = { "fzf" }
              vim.g.beacon_size = 30
              vim.g.beacon_enable = 1
              vim.schedule(function()
                vim.api.nvim_create_autocmd({ "WinEnter" }, {
                  command = "Beacon",
                  group = pluginGroup
                })
              end)
            end)
          end, 500)
        end
      },
      {
        "sindrets/diffview.nvim",
        requires = { lazy("nvim-lua/plenary.nvim") },
        ft = developmentFiles,
        event = "CursorHold"
      },
      {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        event = "VimEnter",
        ft = developmentFiles,
        requires = { lazy("windwp/nvim-autopairs") },
        config = require("configs.nvim-treesitter")
      },
      {
        "windwp/nvim-ts-autotag",
        ft = developmentFiles,
        event = "InsertEnter",
      },
      {
        "neovim/nvim-lspconfig",
        ft = developmentFiles,
        after = { "nvim-treesitter" },
        event = "VimEnter",
        requires = {
          "jose-elias-alvarez/nvim-lsp-ts-utils",
          lazy("williamboman/nvim-lsp-installer"),
          lazy("junegunn/fzf"),
          lazy("folke/lsp-colors.nvim"),
          lazy("gfanto/fzf-lsp.nvim"),
          lazy("MunifTanjim/prettier.nvim"),
          lazy("jose-elias-alvarez/null-ls.nvim"),
        },
        config = require("configs.lsp")
      },
      {
        "L3MON4D3/LuaSnip",
        ft = developmentFiles,
        after = { "nvim-treesitter" },
        event = "CursorHold"
      },
      {
        "hrsh7th/nvim-cmp",
        ft = developmentFiles,
        event = "CursorHoldI",
        after = { "nvim-treesitter", "zenbones.nvim" },
        requires = {
          "onsails/lspkind.nvim",
          "hrsh7th/nvim-cmp",
          {
            "f3fora/cmp-spell",
            ft = { "markdown" },
            event = "VimEnter",
          },
          {
            "mtoohey31/cmp-fish",
            event = "VimEnter",
            ft = { "fish" }
          },
          {
            "hrsh7th/cmp-nvim-lua",
            event = "VimEnter",
            ft = { "lua" }
          },
          lazy("hrsh7th/cmp-emoji"),
          lazy("saadparwaiz1/cmp_luasnip"),
          lazy("hrsh7th/cmp-nvim-lsp"),
          lazy("hrsh7th/cmp-path"),
          lazy("hrsh7th/cmp-buffer"),
        },
        config = require("configs.cmp")
      },
      {
        "folke/trouble.nvim",
        requires = { lazy("kyazdani42/nvim-web-devicons") },
        event = "CursorHold",
        config = function()
          vim.defer_fn(function()
            vim.schedule(function()
              require("trouble").setup()
            end)
          end, 300)
        end
      },
      {
        "rrethy/vim-hexokinase",
        run = "make hexokinase",
        event = "CursorHold",
        config = function()
          vim.g.Hexokinase_highlighters = {"virtual"}
          vim.g.Hexokinase_optInPatterns = {
            "full_hex", "rgb", "rgba", "hsl", "hsla"
          }
        end
      },
      {
        "ellisonleao/glow.nvim",
        ft = { "markdown" },
        event = "CursorHold",
        config = function()
          vim.defer_fn(function()
            vim.schedule(function()
              require("glow").setup({
                style = "dark",
                width = 200,
                border = "rounded",
              })
              vim.keymap.set("n", "<leader>G", ":Glow<CR>", { noremap = true, silent = true })
            end)
          end, 500)
        end
      },
      {
        "folke/todo-comments.nvim",
        requires = {
          lazy("nvim-lua/plenary.nvim"),
        },
        ft = developmentFiles,
        after = { "zenbones.nvim" },
        event = "ColorSchemePre",
        config = function()
          require("todo-comments").setup()
        end
      },
      {
        "nvim-lualine/lualine.nvim",
        requires = {
          lazy("kyazdani42/nvim-web-devicons"),
          lazy("f-person/git-blame.nvim")
        },
        after = { "lush.nvim" },
        event = "ColorSchemePre",
        config = require("configs.lualine")
      },
      {
        "gelguy/wilder.nvim" ,
        after = { "zenbones.nvim" },
        event = "ColorSchemePre",
        requires = {
          lazy("kyazdani42/nvim-web-devicons"),
          lazy("romgrk/fzy-lua-native")
        },
        config = require("configs.wilder")
      },
      {
        "lewis6991/gitsigns.nvim",
        event = "ColorSchemePre",
        after = { "zenbones.nvim" },
        ft = developmentFiles,
        config = function()
          vim.schedule(function()
            require("gitsigns").setup()
          end)
        end
      },
      {
        "nvim-telescope/telescope.nvim",
        event = "VimEnter",
        requires = { lazy("nvim-telescope/telescope-file-browser.nvim")  },
        config = require("configs.telescope")
      },
      {
        "ibhagwan/fzf-lua",
        event = "VimEnter",
        after = { "zenbones.nvim" },
        requires = { lazy("kyazdani42/nvim-web-devicons") },
        config = require("configs.fzf")
      },
      {
        "kyazdani42/nvim-tree.lua",
        event = "VimEnter",
        after = { "zenbones.nvim", "barbar.nvim" },
        requires = { "kyazdani42/nvim-web-devicons" },
        config = require("configs.nvim-tree")
      },
    })
  end
})
