return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufRead",
    opts = {},
    cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add more things to the ensure_installed table protecting against community packs modifying it
      opts.ensure_installed = require("astronvim.utils").list_insert_unique(opts.ensure_installed, {
        "comment",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "jsdoc",
      })
      opts.auto_install = true
    end,
  },
}
