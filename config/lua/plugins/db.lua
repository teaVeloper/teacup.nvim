-- Database
return {
    {
        "kristijanhusak/vim-dadbod-ui",
        opt = true,
    },
    {
        "kristijanhusak/vim-dadbod-completion",
        opt = true,
    },
    "tpope/vim-dadbod",
    opt = true,
    requires = {
        "kristijanhusak/vim-dadbod-ui",
        "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
        local M = {}

        local function db_completion()
            require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
        end

        function M.setup()
            vim.g.db_ui_save_location = vim.fn.stdpath("config") .. require("plenary.path").path.sep .. "db_ui"

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "sql",
                },
                command = [[setlocal omnifunc=vim_dadbod_completion#omni]],
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "sql",
                    "mysql",
                    "plsql",
                },
                callback = function()
                    vim.schedule(db_completion)
                end,
            })
        end

        return M
    end,
    cmd = { "DBUIToggle", "DBUI", "DBUIAddConnection", "DBUIFindBuffer", "DBUIRenameBuffer", "DBUILastQueryInfo" },
}
