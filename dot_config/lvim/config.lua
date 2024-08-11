-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


-- 
vim.g.maplocalleader = ";"
-- lvim.log.level = "debug"
-- Fuck Jupyter
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
vim.g.python3_host_prog=vim.fn.expand("~/.virtualenvs/neovim/bin/python3")


lvim.plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    lazy = false
  },

  {
    "zbirenbaum/copilot-cmp",
    after = {"copilot.lua"},
    config = function ()
      require("copilot_cmp").setup()
    end
  },

  {
      "vhyrro/luarocks.nvim",
      priority = 1001, -- this plugin needs to run before anything else
      opts = {
          rocks = { "magick" },
      },
  },

  {
    -- for lsp features in code cells / embedded code
    'jmbuhr/otter.nvim',
    dev = false,
    dependencies = {
      {
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
      },
    },
    opts = {},
  },

  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = true,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt install lua5.1
      -- sudo apt installl luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        -- window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview' },
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 30,
        kitty_method = 'normal',
      }

      local function clear_all_images()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images { buffer = bufnr }
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images { buffer = buf }
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = vim.api.nvim_create_buf(false, true)
        local win_width = vim.api.nvim_get_option_value('columns', {})
        local win_height = vim.api.nvim_get_option_value('lines', {})
        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          style = 'minimal',
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })
        vim.keymap.set('n', 'q', function()
          vim.api.nvim_win_close(win, true)
          img.global_state.options.max_height_window_percentage = og_max_height
        end, { buffer = buf })
        return { buf = buf, win = win }
      end

      local handle_zoom = function(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then
          return
        end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      vim.keymap.set('n', '<leader>io', function()
        local bufnr = vim.api.nvim_get_current_buf()
        handle_zoom(bufnr)
      end, { buffer = true, desc = 'image [o]pen' })

      vim.keymap.set('n', '<leader>ic', clear_all_images, { desc = 'image [c]lear' })
    end,
  },

  {
    'quarto-dev/quarto-nvim',
    ft = { 'quarto' },
    dev = false,
    opts = {
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
    "stevearc/dressing.nvim"
  },

  {
    "coffebar/transfer.nvim",
    lazy = true,
    cmd = { "TransferInit", "DiffRemote", "TransferUpload", "TransferDownload", "TransferDirDiff", "TransferRepeat" },
    opts = {},
  },

  { "Olical/conjure" },

  { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
    -- for complete functionality (language features)
    'quarto-dev/quarto-nvim',
    ft = { 'quarto' },
    dev = false,
    opts = {},
    dependencies = {
      -- for language features in code cells
      -- configured in lua/plugins/lsp.lua and
      -- added as a nvim-cmp source in lua/plugins/completion.lua
      'jmbuhr/otter.nvim',
    },
  },

  { -- directly open ipynb files as quarto docuements
    -- and convert back behind the scenes
    'GCBallesteros/jupytext.nvim',
    opts = {
      custom_language_formatting = {
        python = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto',
        },
        r = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto',
        },
      },
    },
  },

  { 'milanglacier/yarepl.nvim', config = true },

  { -- preview equations
    'jbyuki/nabla.nvim',
    keys = {
      { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
    },
  },
  { -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    'jpalardy/vim-slime',
    dev = false,
    init = function()
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function()
        require('otter.tools.functions').is_otter_language_context 'python'
      end

      vim.cmd [[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]]

      vim.g.slime_target = 'kitty'
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true

    end,
  },
  -- TODO: this is cleaner but it just doesn't fucking workk
  {
    "benlubas/molten-nvim",
    enable = false,
    dependencies = { "image.nvim" },
    ft = { "python", "norg", "markdown", "quarto" }, -- this is just to avoid loading image.nvim, loading molten at the start has minimal startup time impact
    dev = true,
    init = function()
      -- vim.g.molten_cover_empty_lines = true
      -- vim.g.molten_comment_string = "# %%"
      vim.keymap.set({ "v", "n" }, "<leader><leader>R", "<Cmd>MoltenEvaluateVisual<CR>")

      -- vim.g.molten_auto_image_popup = true
      -- vim.g.molten_show_mimetype_debug = true
      vim.g.molten_auto_open_output = false
      vim.g.molten_image_provider = "image.nvim"
      -- vim.g.molten_output_show_more = true
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_output_win_max_height = 12
      -- vim.g.molten_output_virt_lines = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_use_border_highlights = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_wrap_output = true
      vim.g.molten_tick_rate = 142

      vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>", { desc = "Initialize Molten", silent = true })
      vim.keymap.set("n", "<localleader>ir", function()
        vim.cmd("MoltenInit rust")
      end, { desc = "Initialize Molten for Rust", silent = true })
      vim.keymap.set("n", "<localleader>ip", function()
        local venv = os.getenv("VIRTUAL_ENV")
        if venv ~= nil then
          -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
          venv = string.match(venv, "/.+/(.+)")
          vim.cmd(("MoltenInit %s"):format(venv))
        else
          vim.cmd("MoltenInit python3")
        end
      end, { desc = "Initialize Molten for python3", silent = true, noremap = true })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          -- quarto code runner mappings
          local r = require("quarto.runner")
          vim.keymap.set("n", "<localleader>rc", r.run_cell, { desc = "run cell", silent = true })
          vim.keymap.set("n", "<localleader>ra", r.run_above, { desc = "run cell and above", silent = true })
          vim.keymap.set("n", "<localleader>rb", r.run_below, { desc = "run cell and below", silent = true })
          vim.keymap.set("n", "<localleader>rl", r.run_line, { desc = "run line", silent = true })
          vim.keymap.set("n", "<localleader>rA", r.run_all, { desc = "run all cells", silent = true })
          vim.keymap.set("n", "<localleader>RA", function()
            r.run_all(true)
          end, { desc = "run all cells of all languages", silent = true })

          -- setup some molten specific keybindings
          vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>",
            { desc = "evaluate operator", silent = true })
          vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
          vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv",
            { desc = "execute visual selection", silent = true })
          vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>",
            { desc = "open output window", silent = true })
          vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
          vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
          local open = false
          vim.keymap.set("n", "<localleader>ot", function()
            open = not open
            vim.fn.MoltenUpdateOption("auto_open_output", open)
          end)

          -- if we're in a python file, change the configuration a little
          if vim.bo.filetype == "python" then
            vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
            vim.fn.MoltenUpdateOption("molten_virt_text_output", false)
          end
        end,
      })

      local imb = function(e)
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()

          local try_kernel_name = function()
            local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
            return metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)

          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv("VIRTUAL_ENV")
            if venv ~= nil then
              kernel_name = string.match(venv, "/.+/(.+)")
            end
          end

          if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(("MoltenInit %s"):format(kernel_name))
          end
          vim.cmd("MoltenImportOutput")
        end)
      end

      -- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
      --   vim.api.nvim_create_autocmd("BufEnter", {
      --     pattern = { "*.ipynb" },
      --     callback = function(e)
      --       if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
      --         imb(e)
      --       end
      --     end,
      --   })
      --
      --   -- automatically import output chunks from a jupyter notebook
      --   vim.api.nvim_create_autocmd("BufAdd", {
      --     pattern = { "*.ipynb" },
      --     callback = imb,
      --   })
      --
      --   -- automatically export output chunks to a jupyter notebook
      --   vim.api.nvim_create_autocmd("BufWritePost", {
      --     pattern = { "*.ipynb" },
      --     callback = function()
      --       if require("molten.status").initialized() == "Molten" then
      --         vim.cmd("MoltenExportOutput!")
      --       end
      --     end,
      --   })
    end,
  },

  -- color html colors
  {
    'NvChad/nvim-colorizer.lua',
    enabled = true,
    opts = {
      filetypes = { '*' },
      user_default_options = {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue or blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = false, -- 0xAARRGGBB hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = 'background', -- Set the display mode.
        -- Available methods are false / true / "normal" / "lsp" / "both"
        -- True is same as normal
        tailwind = false, -- Enable tailwind colors
        -- parsers can contain values used in |user_default_options|
        sass = { enable = false, parsers = { 'css' } }, -- Enable sass colors
        virtualtext = '■',
        -- update color values even if buffer is not focused
        -- example use: cmp_menu, cmp_docs
        always_update = false,
        -- all the sub-options of filetypes apply to buftypes
      },
      buftypes = {},
    },
  },
  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    "linux-cultist/venv-selector.nvim",
      dependencies = {
        "neovim/nvim-lspconfig", 
        "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
        { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
      },
    lazy = false,
    branch = "regexp", -- This is the regexp branch, use this for the new version
    config = function()
        require("venv-selector").setup()
     end,
  },
}

vim.list_extend(lvim.builtin.cmp.sources, {
  { name = "otter" },
  { name = "copilot"},
  { name = "conjure"}
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

-- TERMINAL 
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=100 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=30 direction=horizontal<cr>", "Split horizontal" },
}

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<c-s>", "<cmd>lua require('copilot.suggestion').toggle_auto_trigger()<CR>", opts)


local function new_terminal(lang)
  vim.cmd('vsplit term://' .. lang)
end

local function new_terminal_python()
  new_terminal 'python'
end

local function new_terminal_ipython()
  new_terminal 'ipython --no-confirm-exit'
end

local function new_terminal_julia()
  new_terminal 'julia'
end

local function new_terminal_shell()
  new_terminal '$SHELL'
end

local function get_otter_symbols_lang()
  local otterkeeper = require'otter.keeper'
  local main_nr = vim.api.nvim_get_current_buf()
  local langs = {}
  for i,l in ipairs(otterkeeper.rafts[main_nr].languages) do
    langs[i] = i .. ': ' .. l
  end
  -- promt to choose one of langs
  local i = vim.fn.inputlist(langs)
  local lang = otterkeeper.rafts[main_nr].languages[i]
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    otter = {
      lang = lang
    }
  }
  -- don't pass a handler, as we want otter to use it's own handlers
  vim.lsp.buf_request(main_nr, ms.textDocument_documentSymbol, params, nil)
end

local is_code_chunk = function()
  local current, _ = require('otter.keeper').get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

local insert_code_chunk = function(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local insert_py_chunk = function()
  insert_code_chunk 'python'
end

local insert_lua_chunk = function()
  insert_code_chunk 'lua'
end

local insert_julia_chunk = function()
  insert_code_chunk 'julia'
end

local insert_bash_chunk = function()
  insert_code_chunk 'bash'
end

local insert_ojs_chunk = function()
  insert_code_chunk 'ojs'
end

vim.keymap.set("n", "<leader>os", get_otter_symbols_lang, {desc = "otter [s]ymbols"})
-- TERMINAL 
lvim.builtin.which_key.mappings["q"] = {
  name = "Quarto",
  E = { ":lua require('otter').export(true)<cr>", "[E]xport with overwrite" },
  a = { ":QuartoActivate<cr>", "[a]ctivate" },
  e = { ":lua require('otter').export()<cr>", "[e]xport" },
  h = { ":QuartoHelp ", "[h]elp" },
  p = { ":lua require'quarto'.quartoPreview()<cr>", "[p]review" },
  q = { ":lua require'quarto'.quartoClosePreview()<cr>", "[q]uiet preview" },
  r = {
    name = "[r]un",
    a = { ":QuartoSendAll<cr>", "run [a]ll" },
    b = { ":QuartoSendBelow<cr>", "run [b]elow" },
    r = { ":QuartoSendAbove<cr>", "to cu[r]sor" },
  },
}

-- OTTER
lvim.builtin.which_key.mappings["o"] = {
 name = "Otter & Code",
 a = { require'otter'.activate, "otter [a]ctivate" },
 b = { insert_bash_chunk, "[b]ash code chunk" },
 c = { "O# %%<cr>", "magic [c]omment code chunk # %%" },
 d = { require'otter'.deactivate, "otter [d]eactivate" },
 j = { insert_julia_chunk, "[j]ulia code chunk" },
 l = { insert_lua_chunk, "[l]lua code chunk" },
 o = { insert_ojs_chunk, "[o]bservable js code chunk" },
 p = { insert_py_chunk, "[p]ython code chunk" },
}


local function mark_terminal()
  local job_id = vim.b.terminal_job_id
  vim.print('job_id: ' .. job_id)
end

local function set_terminal()
  vim.fn.call('slime#config', {})
end

lvim.builtin.which_key.mappings["c"] = {
  name = "[c]ode / [c]ell / [c]hunk",
  i = { new_terminal_ipython, "new [i]python terminal" },
  j = { new_terminal_julia, "new [j]ulia terminal" },
  n = { new_terminal_shell, "[n]ew terminal with shell" },
  p = { new_terminal_python, "new [p]ython terminal" },
  m = { mark_terminal, "[m]ark terminal" },
  s = { set_terminal, "[s]et terminal" },
}

-- Enable core plugins
lvim.builtin.project.active = true
lvim.builtin.project.silent_chdir = false

lvim.builtin.nvimtree.setup.update_focused_file =  {
    enable = true,
    update_root = true
  }

lvim.colorscheme = "tokyonight"

local util = require 'lspconfig.util'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
local lspconfig = require 'lspconfig'
lspconfig.marksman.setup {
  capabilities = capabilities,
  filetypes = { 'markdown', 'quarto' },
  root_dir = util.root_pattern('.git', '.marksman.toml', '_quarto.yml'),
}

require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snips' } }

local luasnip = require 'luasnip'
luasnip.filetype_extend('quarto', { 'markdown' })

local lsp_flags = {
  allow_incremental_sync = true,
  debounce_text_changes = 150,
}
lspconfig.pyright.setup {
  capabilities = capabilities,
  flags = lsp_flags,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
  root_dir = function(fname)
    return util.root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt')(fname) or util.path.dirname(fname)
  end,
}
lspconfig.cssls.setup {
  capabilities = capabilities,
  flags = lsp_flags,
}

lspconfig.html.setup {
  capabilities = capabilities,
  flags = lsp_flags,
}

lspconfig.emmet_language_server.setup {
  capabilities = capabilities,
  flags = lsp_flags,
}

lspconfig.yamlls.setup {
  capabilities = capabilities,
  flags = lsp_flags,
  settings = {
    yaml = {
      schemaStore = {
        enable = true,
        url = '',
      },
    },
  },
}
lspconfig.jsonls.setup {
  capabilities = capabilities,
  flags = lsp_flags,
}

-- TODO: this just doesn't work
-- -- change the configuration when editing a python file
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "*.py",
--   callback = function(e)
--     if string.match(e.file, ".otter.") then
--       return
--     end
--     if require("molten.status").initialized() == "Molten" then
--       vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", false)
--       vim.fn.MoltenUpdateOption("molten_virt_text_output", false)
--     end
--   end,
-- })


-- -- Undo those config changes when we go back to a markdown or quarto file
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.qmd", "*.md", "*.ipynb" },
--   callback = function()
--     if require("molten.status").initialized() == "Molten" then
--       vim.fn.MoltenUpdateOption("molten_virt_lines_off_by_1", true)
--       vim.fn.MoltenUpdateOption("molten_virt_text_output", true)
--     end
--   end,
-- })

