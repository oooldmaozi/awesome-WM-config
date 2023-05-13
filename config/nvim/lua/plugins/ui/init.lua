local keys = { { "n", "n" }, { "n", "N" } }

return {
  {
    "rebelot/heirline.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.ui.heirline").setup()
    end,
  },
  { "folke/which-key.nvim" },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    config = function()
      require("indent_blankline").setup({ char = "│", show_current_context = true })
    end,
  },
  {
    "kevinhwang91/nvim-hlslens",
    event = "BufRead",
    keys = keys,
    config = function()
      local wk = require("which-key")
      require("hlslens").setup({ calm_down = true, nearest_only = true })

      wk.register({
        n = {
          [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
          "Next match",
        },
        N = {
          [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
          "Previous match",
        },
      })
    end,
  },
  { "phaazon/hop.nvim", config = true },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    config = function()
      local wk = require("which-key")
      local gs = require("gitsigns")

      local prev_or_next = function(key, action)
        return function()
          if vim.wo.diff then
            return key
          end
          vim.schedule(action)

          return "<Ignore>"
        end
      end

      gs.setup({
        on_attach = function(bufnr)
          wk.register({
            buffer = bufnr,
            ["<leader>"] = {
              g = {
                name = "+git",
                s = {
                  name = "+status | +stage",
                  {
                    h = { gs.stage_hunk, "Stage hunk" },
                    b = { gs.stage_buffer, "Stage buffer" },
                  },
                },
                b = { gs.toggle_current_line_blame, "Blame" },
                u = { gs.undo_stage_hunk, "Undo stage" },
                r = {
                  name = "+reset",
                  H = { gs.reset_hunk, "Reset hunk" },
                  B = { gs.reset_buffer, "Reset buffer" },
                },
                p = { gs.preview_hunk, "Preview hunk" },
                -- TODO: Close the left window to quit
                d = { gs.diffthis, "Diff this" },
              },
            },
            ["]c"] = { prev_or_next("]c", gs.next_hunk), "Go to next hunk" },
            ["[c"] = { prev_or_next("[c", gs.prev_hunk), "Go to previous hunk" },
          })

          wk.register({
            ["<leader>"] = {
              g = {
                name = "+git",
                s = { name = "+stage", { h = { gs.stage_hunk, "Stage hunk" } } },
                r = { name = "+reset", H = { gs.reset_hunk, "Reset hunk" } },
              },
            },
          }, { mode = "v" })

          wk.register({
            i = {
              name = "+gitsigns",
              h = { gs.select_hunk, "Select hunk" },
            },
          }, { mode = { "o", "x" } })
        end,
      })
    end,
  },
  {
    "ziontee113/icon-picker.nvim",
    cmd = "IconPickerInsert",
    config = function()
      require("icon-picker").setup({
        disable_legacy_commands = true,
      })
    end,
  },
  {
    "windwp/nvim-spectre",
    config = function()
      local sep =
        "══════════════════════════════════"
      require("spectre").setup({
        line_sep_start = sep,
        result_padding = "  ",
        line_sep = sep,
      })
    end,
  },
  {
    "levouh/tint.nvim",
    event = "BufRead",
    config = function()
      require("tint").setup({
        ignore = { "WinSeparator", "Status.*", "IndentBlankline.*", "SignColumn", "EndOfBuffer" }, -- Highlight group patterns to ignore, see `string.find`
        ignorefunc = function(winid)
          local bufid = vim.api.nvim_win_get_buf(winid)
          local buftype = vim.api.nvim_buf_get_option(bufid, "buftype")

          -- Tint normal buffer
          return buftype ~= ""
        end,
      })
    end,
  },
  { "stevearc/dressing.nvim", event = "VeryLazy", config = true },
  {
    "jinh0/eyeliner.nvim",
    event = "VeryLazy",
    config = function()
      require("eyeliner").setup({
        highlight_on_key = true, -- show highlights only after keypress
        dim = true, -- dim all other characters if set to true (recommended!)
      })
    end,
  },
}
