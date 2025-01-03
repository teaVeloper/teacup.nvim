-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = augroup("kickstart-highlight-yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        -- "man",
        "notify",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+://") then
            return
        end
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Autocommands to toggle line numbers on visual mode
local toggleNumbersGroup = augroup("ToggleNumbers")
vim.api.nvim_create_autocmd("ModeChanged", {
    group = toggleNumbersGroup,
    pattern = "*:[vV\x16]*",
    callback = function()
        vim.opt.number = true
        vim.opt.relativenumber = true
    end,
})
vim.api.nvim_create_autocmd("Modechanged", {
    group = toggleNumbersGroup,
    pattern = "[vV\x16]*:*",
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end,
})

-- Function to get the base filetype from the filename
local function get_base_filetype(filename)
    -- Extract the base extension (e.g., 'toml' from 'config.toml.jinja2')
    local base_ext = filename:match("^.+%.([^.]+)%.[^.]+$")
    return base_ext
end

-- Autocommand to set the filetype if its a template
local patterns = { "*.jinja2", "*.tpl" }
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = patterns,
    group = augroup("TemplateFileType"),
    callback = function(args)
        local base_ft = get_base_filetype(args.file)
        if base_ft then
            vim.bo.filetype = base_ft
        end
    end,
})
