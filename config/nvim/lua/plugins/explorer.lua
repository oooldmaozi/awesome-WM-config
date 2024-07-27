return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        cond = not vim.g.vscode,
        version = "2.*",
        opts = {
          hint = "floating-big-letter",
        },
        config = true,
      },
    },
    cond = not vim.g.vscode,
    branch = "v3.x",
    cmd = "Neotree",
    keys = { { "<leader>n", "<cmd>Neotree reveal<cr>", desc = "Neotree" } },
    opts = {
      filesystem = {
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
        },
        window = {
          mappings = {
            ["<space>"] = "none",
            ["s"] = "none",
          },
          fuzzy_finder_mappings = {
            ["<C-j>"] = "move_cursor_down",
            ["<C-k>"] = "move_cursor_up",
          },
        },
      },
      window = {
        mappings = {
          ["<cr>"] = "open_with_window_picker",
          ["l"] = "open",
          ["L"] = "focus_preview",
          ["h"] = "close_node",
        },
      },
    },
  },
}
