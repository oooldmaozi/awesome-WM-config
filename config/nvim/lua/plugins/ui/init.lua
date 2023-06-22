local keys = { { "n", "n" }, { "n", "N" } }
local utils = require("hnbnh.utils")

local icons = {
  diagnostics = {
    error = " ",
    warn = " ",
    hint = " ",
    info = " ",
  },
}

return {
  {
    "rebelot/heirline.nvim",
    event = "VeryLazy",
    enabled = false,
    config = function()
      require("plugins.ui.heirline").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = "auto",
          component_separators = " ",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.error,
                warn = icons.diagnostics.warn,
                hint = icons.diagnostics.hint,
                info = icons.diagnostics.info,
              },
            },
            {
              "diff",
              symbols = {
                added = " ",
                modified = " ",
                removed = " ",
              },
            },
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = {
                left = 1,
                right = 0,
              },
            },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          },
          lualine_x = {
            {
              function()
                return "  " .. require("dap").status()
              end,
              cond = function()
                return package.loaded["dap"] and require("dap").status() ~= ""
              end,
              color = utils.fg("Debug"),
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "neo-tree", "quickfix" },
      }
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local ret = (diag.error and icons.diagnostics.error .. diag.error .. " " or "")
            .. (diag.warning and icons.diagnostics.warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    config = function()
      require("incline").setup()
      local colors = require("catppuccin.palettes").get_palette("mocha")

      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = colors.yellow, guifg = colors.crust },
            InclineNormalNC = { guifg = colors.yellow, guibg = colors.crust },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    cmd = "Neotree",
    lazy = false,
    config = function()
      require("neo-tree").setup({
        filesystem = {
          use_libuv_file_watcher = true,
          window = {
            mappings = {
              ["Y"] = "yank_path",
            },
            fuzzy_finder_mappings = {
              ["<C-j>"] = "move_cursor_down",
              ["<C-k>"] = "move_cursor_up",
            },
          },
          commands = {
            yank_path = function(state)
              vim.fn.setreg("+", state.tree:get_node().path)
              print("Yanked path to clipboard")
            end,
          },
        },
        window = {
          mappings = {
            ["l"] = "open",
            ["L"] = "focus_preview",
            ["h"] = "close_node",
          },
        },
      })
    end,
  },
  { "HiPhish/nvim-ts-rainbow2" },
  {
    "nvim-zh/colorful-winsep.nvim",
    config = true,
    opts = {
      create_event = function()
        local colorful_winsep = require("colorful-winsep")
        local win_n = require("colorful-winsep.utils").calculate_number_windows()
        if win_n == 2 then
          local win_id = vim.fn.win_getid(vim.fn.winnr("h"))
          local filetype = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win_id), "filetype")
          if filetype == "neo-tree" then
            colorful_winsep.NvimSeparatorDel()
          end
        end
      end,
    },
    event = { "WinNew" },
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
    enabled = false,
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
    enabled = false,
    config = function()
      require("eyeliner").setup({
        highlight_on_key = true, -- show highlights only after keypress
        dim = true, -- dim all other characters if set to true (recommended!)
      })
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
        end,
      },
      {
        "S",
        mode = { "o", "x" },
        function()
          require("flash").treesitter()
        end,
      },
    },
  },
  { "pwntester/octo.nvim", cmd = "Octo", config = true },
}
