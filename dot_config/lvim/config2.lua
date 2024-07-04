-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


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
      "benlubas/molten-nvim",
      version = "^1.0.0",
      build = ":UpdateRemotePlugins",
      init = function()
          -- this is an example, not a default. Please see the readme for more configuration options
          vim.g.molten_image_provider = "image.nvim"
          vim.g.molten_output_win_max_height = 12
          -- I find auto open annoying, keep in mind setting this option will require setting
          -- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
          -- vim.g.molten_auto_open_output = false

          -- this guide will be using image.nvim
          -- Don't forget to setup and install the plugin if you want to view image outputs
          vim.g.molten_image_provider = "image.nvim"

          -- optional, I like wrapping. works for virt text and the output window
          vim.g.molten_wrap_output = true

          -- Output as virtual text. Allows outputs to always be shown, works with images, but can
          -- be buggy with longer images
          vim.g.molten_virt_text_output = true

          -- this will make it so the output shows up below the \`\`\` cell delimiter
          vim.g.molten_virt_lines_off_by_1 = true

          vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator", silent = true })
          vim.keymap.set("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
          vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
          vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { desc = "execute visual selection", silent = true })
          vim.keymap.set("n", "<localleader>oh", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
          vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

          -- if you work with html outputs:
          vim.keymap.set("n", "<localleader>mx", ":MoltenOpenInBrowser<CR>", { desc = "open output in browser", silent = true })
      end,
  },
  {
      "vhyrro/luarocks.nvim",
      priority = 1001, -- this plugin needs to run before anything else
      opts = {
          rocks = { "magick" },
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
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
      }
  },
  {
    "quarto-dev/quarto-nvim",
    config = function()
      require("quarto").setup({
      })
    end,
  }

}



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

-- Jupyter Molten 
vim.keymap.set("n", "<localleader>ip", function()
  -- Construct the relative path to check for the .venv directory
  local venv_path = vim.fn.getcwd() .. "/.venv"

  -- Check if the .venv/ directory exists in the current working directory
  if vim.fn.isdirectory(venv_path) == 1 then
    -- Use the relative .venv path if it exists
    vim.cmd(("MoltenInit %s"):format(venv_path))
  else
    -- Fallback to the VIRTUAL_ENV environment variable
    local venv = os.getenv("VIRTUAL_ENV")
    if venv ~= nil then
      venv = string.match(venv, "/.+/(.+)")
      vim.cmd(("MoltenInit %s"):format(venv))
    else
      -- Default to python3 if no environment is found
      vim.cmd("MoltenInit python3")
    end
  end
end, { desc = "Initialize Molten for python3", silent = true })

