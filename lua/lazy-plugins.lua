-- [[ Configure plugins ]]
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require("lazy").setup({
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gvdiffsplit" },
    keys = {
      {
        "<leader>gg",
        function()
          local is_wide = require("utils").is_wide()
          vim.cmd(is_wide and ":vertical " .. "Git" or ":" .. "Git")
          if is_wide then
            vim.cmd.wincmd("10<")
          end
        end,
        desc = "Open Fugitive",
      },
      {
        "<leader>gd",
        ":Gvdiffsplit!<CR>",
        desc = "[D]iff view",
      },
      {
        "<leader>gl",
        ":Git log<CR>",
        desc = "Git [l]og",
      },
    },
  },

  -- Detect tabstop and shiftwidth automatically
  {
    "tpope/vim-sleuth",
    event = "BufRead",
  },

  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    event = "BufRead",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { "williamboman/mason.nvim", opts = {} },
      "nvimtools/none-ls.nvim",
      "jay-babu/mason-null-ls.nvim",
      "williamboman/mason-lspconfig.nvim",
      "b0o/schemastore.nvim",

      -- Useful status updates for LSP
      {
        "j-hui/fidget.nvim",
        opts = {},
      },

      -- Additional lua configuration, makes nvim stuff amazing!
      "folke/neodev.nvim",
    },
  },

  {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "BufRead",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has("win32") == 1 then
            return
          end
          return "make install_jsregexp"
        end)(),
      },
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind.nvim",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
    },
  },

  -- Useful plugin to show you pending keybinds.
  { "folke/which-key.nvim", opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ "n", "v" }, "]g", function()
          if vim.wo.diff then
            return "]g"
          end
          vim.schedule(function() gs.next_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Jump to next hunk" })

        map({ "n", "v" }, "[g", function()
          if vim.wo.diff then
            return "[g"
          end
          vim.schedule(function() gs.prev_hunk() end)
          return "<Ignore>"
        end, { expr = true, desc = "Jump to previous hunk" })

        -- Actions
        -- visual mode
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage git hunk" })
        map("v", "<leader>gh", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset git hunk" })
        -- normal mode
        map("n", "<leader>gh", gs.reset_hunk, { desc = "Reset hunk" })
        map("n", "<leader>gr", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage hunk" })
        -- map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        -- map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        -- map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        -- map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>gb", function() gs.blame_line({ full = false }) end, { desc = "Blame line" })
        -- map('n', '<leader>gd', gs.diffthis, { desc = 'Git diff' })
        -- map('n', '<leader>gD', function()
        --   gs.diffthis '~'
        -- end, { desc = 'Git diff against last commit' })

        -- Toggles
        -- map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        -- map('n', '<leader>td', gs.toggle_deleted, { desc = 'Toggle git show deleted' })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
      end,
    },
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      local dotenv = {
        icon = "",
        name = "Dotenv",
        color = "#faf743",
        cterm_color = "227",
      }
      require("nvim-web-devicons").setup({
        override = {
          astro = {
            icon = "󱎯",
            name = "Astro",
            color = "#ec682c",
          },
        },
        override_by_filename = {
          [".env.test"] = dotenv,
          [".env.local"] = dotenv,
          [".env.development"] = dotenv,
          [".env.dev"] = dotenv,
          [".env.example"] = dotenv,
        },
      })
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        terminal_colors = false,
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  {
    -- Set lualine as statusline
    "nvim-lualine/lualine.nvim",
    -- See `:help lualine.txt`
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local lualine = require("lualine")

      lualine.setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = "|",
          section_separators = "",
        },
      })
      local config = lualine.get_config()
      table.insert(config.sections.lualine_c, { "searchcount" })

      lualine.setup(config)
    end,
  },

  {
    -- Add indentation guides even on blank lines
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = "ibl",
    opts = {
      indent = {
        char = "▏",
      },
      scope = { enabled = true },
    },
  },

  -- "gc" to comment visual regions/lines
  { "numToStr/Comment.nvim", opts = {}, event = "BufRead" },

  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-context",
        event = "BufRead",
        cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
        config = function()
          require("treesitter-context").setup({})
          vim.api.nvim_set_hl(0, "TreesitterContext", { bg = require("tokyonight.colors").moon().bg })
        end,
      },
      { "nvim-treesitter/nvim-treesitter-textobjects", event = "BufRead" },
      { "windwp/nvim-ts-autotag", event = "BufRead", opts = {} },
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        config = function()
          ---@diagnostic disable-next-line: missing-fields
          require("ts_context_commentstring").setup({
            enable_autocmd = false,
          })
          ---@diagnostic disable-next-line: missing-fields
          require("Comment").setup({
            pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
          })
        end,
      },
    },
    build = ":TSUpdate",
  },

  {
    "kylechui/nvim-surround",
    event = "BufRead",
    opts = {},
  },

  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = { enabled = false },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      redirect = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { silent = true },
        signature = { enabled = true },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 100,
    config = function()
      local notify = require("notify")
      notify.setup()
      local banned_messages = { "No information available" }
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, ...)
        for _, banned in ipairs(banned_messages) do
          if msg == banned then
            return
          end
        end
        return notify(msg, ...)
      end
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- event = "VeryLazy",
    keys = {
      {
        "<leader>tb",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local btm = Terminal:new({
            cmd = "btm",
            hidden = true,
            direction = "float",
            float_opts = {
              width = function()
                local width = vim.o.co
                return width - math.floor(width / 7.5)
              end,
              height = function()
                local height = vim.o.lines
                return height - math.floor(height / 10)
              end,
            },
          })
          btm:toggle()
        end,
        desc = "btm",
      },
    },
    opts = {},
  },

  {
    "echasnovski/mini.move",
    keys = {
      { "<M-h>", mode = "n", desc = "Move line left" },
      { "<M-j>", mode = "n", desc = "Move line down" },
      { "<M-k>", mode = "n", desc = "Move line up" },
      { "<M-l>", mode = "n", desc = "Move line right" },
      { "<M-h>", mode = "v", desc = "Move selection left" },
      { "<M-j>", mode = "v", desc = "Move selection down" },
      { "<M-k>", mode = "v", desc = "Move selection up" },
      { "<M-l>", mode = "v", desc = "Move selection right" },
    },
    opts = {
      mappings = {
        left = "<M-h>",
        right = "<M-l>",
        down = "<M-j>",
        up = "<M-k>",
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_down = "<M-j>",
        line_up = "<M-k>",
      },
    },
  },
  {
    "echasnovski/mini.splitjoin",
    keys = {
      { "<leader>s", function() require("mini.splitjoin").toggle() end, desc = "[S]plit/join" },
    },
    opts = {},
  },

  {
    "nguyenvukhang/nvim-toggler",
    keys = {
      { "<leader>i", function() require("nvim-toggler").toggle() end, desc = "[I]nvert word meaning" },
    },
    opts = {},
  },

  {
    "RRethy/vim-illuminate",
    event = "BufRead",
    keys = {
      { "]]", function() require("illuminate").goto_next_reference() end, desc = "Next reference" },
      { "[[", function() require("illuminate").goto_prev_reference() end, desc = "Previous reference" },
    },
    config = function()
      local opts = { bg = require("tokyonight.colors").moon().bg_highlight }
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", opts)
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", opts)
      vim.api.nvim_set_hl(0, "IlluminatedWordText", {})

      require("illuminate").configure({})
    end,
  },

  {
    "kevinhwang91/nvim-ufo",
    event = "LspAttach",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    opts = {},
  },

  {
    "luukvbaal/statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          { text = { " ", builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
          { text = { "%s" }, click = "v:lua.ScSa" },
        },
      })
    end,
  },

  {
    "hiphish/rainbow-delimiters.nvim",
    config = function() require("rainbow-delimiters.setup").setup({}) end,
  },

  {
    "3rd/image.nvim",
    event = "BufRead *.{png,jpg,jpeg,gif,webp}",
    ft = "markdown",
    opts = {
      tmux_show_only_in_active_window = true,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
    },
  },

  {
    "vladdoster/remember.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>m",
        function()
          require("harpoon"):list():append()
          vim.notify("Added to harpoon", vim.log.levels.INFO)
        end,
        desc = "[M]ark for harpoon list",
      },
      { "<leader>h", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Open [h]arpoon" },
      { "]b", function() require("harpoon"):list():prev() end, desc = "Previous harpoon mark" },
      { "]b", function() require("harpoon"):list():next() end, desc = "Next harpoon mark" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "which_key_ignore" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "which_key_ignore" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "which_key_ignore" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "which_key_ignore" },
      { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "which_key_ignore" },
    },
    opts = {
      settings = {
        save_on_toggle = true,
      },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    },
    -- Setup neo-tree when pressed a key...
    keys = {
      { "<leader>o", ":Neotree toggle<CR>", desc = "Open neotree" },
    },
    --- ...or when opened a directory (`nvim .`)
    config = require("neo-tree-setup").setup,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", function() require("trouble").toggle() end, desc = "Toggle menu" },
      {
        "<leader>xw",
        function() require("trouble").toggle("workspace_diagnostics") end,
        desc = "Toggle workspace diagnostics menu",
      },
      {
        "<leader>xd",
        function() require("trouble").toggle("document_diagnostics") end,
        desc = "Toggle document diagnostics menu",
      },
      { "<leader>xq", function() require("trouble").toggle("quickfix") end, desc = "Toggle quickfix menu" },
      { "<leader>xl", function() require("trouble").toggle("loclist") end, desc = "Toggle location list menu" },
      { "<leader>xt", function() require("trouble").toggle("todo") end, desc = "Toggle todo list" },
      { "<C-n>", function() require("trouble").next({ skip_groups = true, jump = true }) end },
      { "<C-p>", function() require("trouble").previous({ skip_groups = true, jump = true }) end },
    },
    opts = {
      height = 20,
      width = 87,
      position = "bottom",
    },
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufRead",
    opts = {},
  },

  {
    "mbbill/undotree",
    keys = {
      { "<leader>fu", "<CMD>UndotreeToggle<CR><CMD>UndotreeFocus<CR>", desc = "Undo tree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 3
      vim.g.undotree_SplitWidth = 40
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    keys = { { "<leader>M", ":MarkdownPreview<CR>", desc = "Open [m]arkdown preview" } },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "BufRead",
    opts = {
      suggestion = { auto_trigger = true },
    },
  },

  {
    "dmmulroy/tsc.nvim",
    cmd = { "TSC" },
    opts = {},
  },

  {
    "wakatime/vim-wakatime",
    event = "BufRead",
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = "BufRead",
    cmd = { "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers", "ColorizerToggle" },
    opts = {
      user_default_options = {
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        AARRGGBB = true, -- 0xAARRGGBB hex codes
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        tailwind = true, -- Enable tailwind colors
        -- update color values even if buffer is not focused
        -- example use: cmp_menu, cmp_docs
        always_update = true,
      },
    },
  },

  -- Yank history
  {
    "gbprod/yanky.nvim",
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
    },
    opts = {},
  },

  -- NOTE: Next Step on Your JSON Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  require("kickstart.plugins.autoformat"),
  require("kickstart.plugins.debug"),

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- vim: ts=2 sts=2 sw=2 et
