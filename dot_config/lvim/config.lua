-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- 
vim.g.maplocalleader = ";"

-- Fuck Jupyter
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
vim.g.python3_host_prog=vim.fn.expand("~/.virtualenvs/neovim/bin/python3")

lvim.plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    after = {"copilot.lua"},
    config = function ()
      require("copilot_cmp").setup()
    end
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    -- Depending on your nvim distro or config you may need to make the loading not lazy
    -- lazy=false,
  },
  {
      "vhyrro/luarocks.nvim",
      priority = 1001, -- this plugin needs to run before anything else
      opts = {
          rocks = { "magick" },
      },
  },
  {
    'jmbuhr/otter.nvim',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
      "3rd/image.nvim",
      dependencies = { "luarocks.nvim" },
      opts = {
        backend = "kitty",
         integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mod = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "norg" },
          },
          html = {
            enabled = false,
          },
          css = {
            enabled = false,
          },
        },
        max_width = 100,
        max_height = 12,
        max_height_window_percentage = math.huge,
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
      }
  },
  {
    'quarto-dev/quarto-nvim',
    ft = { 'quarto' },
    dev = false,
    opts = {
      lspFeatures = {
        languages = { 'r', 'python', 'julia', 'bash', 'lua', 'html', 'dot', 'javascript', 'typescript', 'ojs' },
      },
      codeRunner = {
        enabled = true,
        default_method = 'molten',
      },
    },
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      'jmbuhr/otter.nvim',
    },
  },
  {
    'GCBallesteros/jupytext.nvim',
    opts = {
      custom_language_formatting = {
        python = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto', -- you can set whatever filetype you want here
        },
      },
    },
  },
  {
    'HakonHarnes/img-clip.nvim',
    event = 'BufEnter',
    ft = { 'markdown', 'quarto', 'latex' },
    opts = {
      default = {
        dir_path = 'img',
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require('img-clip').setup(opts)
      vim.keymap.set('n', '<leader>ii', ':PasteImage<cr>', { desc = 'insert [i]mage from clipboard' })
    end,
  },
  {
    'jbyuki/nabla.nvim',
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
    },
  },
  {
    'mrjones2014/smart-splits.nvim',
    build = './kitty/install-kittens.bash'
  },
  {
    'gsuuon/tshjkl.nvim',
    config = true
  },
  {
    "chrisgrieser/nvim-spider", lazy = true
  },
  { 
    "hkupty/iron.nvim",
    config = function(plugins, opts)
      local iron = require("iron.core")

      iron.setup({
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            python = {
              -- Can be a table or a function that
              -- returns a table (see below)
              command = { "python" },
            },
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = require("iron.view").right(60),
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          send_motion = "<space>rc",
          visual_send = "<space>rc",
          send_file = "<space>rf",
          send_line = "<space>rl",
          send_mark = "<space>rm",
          mark_motion = "<space>rmc",
          mark_visual = "<space>rmc",
          remove_mark = "<space>rmd",
          cr = "<space>r<cr>",
          interrupt = "<space>r<space>",
          exit = "<space>rq",
          clear = "<space>rx",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      })

      -- iron also has a list of commands, see :h iron-commands for all available commands
      vim.keymap.set("n", "<space>rs", "<cmd>IronRepl<cr>")
      vim.keymap.set("n", "<space>rr", "<cmd>IronRestart<cr>")
      vim.keymap.set("n", "<space>rF", "<cmd>IronFocus<cr>")
      vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
    end,
  },
  {
    "ChristianChiarulli/swenv.nvim"
  },
  {
    "stevearc/dressing.nvim"
  },
  {
    "coffebar/transfer.nvim",
    lazy = true,
    cmd = { "TransferInit", "DiffRemote", "TransferUpload", "TransferDownload", "TransferDirDiff", "TransferRepeat" },
    opts = {},
  },
}

vim.list_extend(lvim.builtin.cmp.sources, {
  { name = "otter" },
  { name = "copilot"},
})


-- COPILOT
local ok, copilot = pcall(require, "copilot")
if not ok then
return
end

copilot.setup {
  suggestion = {
    keymap = {
      accept = "<c-l>",
      next = "<c-j>",
      prev = "<c-k>",
      dismiss = "<c-h>",
    },
  },
}

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<c-s>", "<cmd>lua require('copilot.suggestion').toggle_auto_trigger()<CR>", opts)

-- TERMINAL 
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=100 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=30 direction=horizontal<cr>", "Split horizontal" },
}

-- Enable core plugins
lvim.builtin.project.active = true

