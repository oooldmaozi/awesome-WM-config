return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    config = function()
      require("catppuccin").setup({
        custom_highlights = function(colors)
          return {
            WinSeparator = { fg = colors.overlay0 },
            YankyPut = { fg = colors.crust, bg = colors.green },
            YankyYanked = { fg = colors.crust, bg = colors.yellow },
          }
        end,
        integrations = {
          aerial = false,
          harpoon = true,
          lsp_trouble = true,
          neotree = true,
          notify = true,
          treesitter_context = true,
        },
      })
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },
}
