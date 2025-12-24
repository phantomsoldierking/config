return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {}, -- Ensure no missing dependencies
    config = function()
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter.configs not found", vim.log.levels.ERROR)
        return
      end

      configs.setup({
        ensure_installed = {
          "vimdoc",
          "javascript",
          "typescript",
          "c",
          "lua",
          "rust",
          "jsdoc",
          "bash",
          "go",
        },

        sync_install = false,
        auto_install = true,

        indent = {
          enable = true,
        },

        highlight = {
          enable = true,

          disable = function(lang, buf)
            if lang == "html" then
              return true
            end

            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats =
              pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              vim.notify(
                "File larger than 100KB, Treesitter disabled",
                vim.log.levels.WARN,
                { title = "Treesitter" }
              )
              return true
            end
          end,

          additional_vim_regex_highlighting = { "markdown" },
        },
      })

      -- Custom templ parser
      local parser_config =
        require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.templ = {
        install_info = {
          url = "https://github.com/vrischmann/tree-sitter-templ.git",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "master",
        },
      }

      vim.treesitter.language.register("templ", "templ")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        multiwindow = false,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })
    end,
  },
}
