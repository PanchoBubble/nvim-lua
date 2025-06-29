return {
    {
        'rmagatti/auto-session',
        config = function()
            vim.o.sessionoptions = "buffers,curdir,tabpages,localoptions"
            require('auto-session').setup({
                auto_session_last_session_dir = vim.fn.stdpath "data" .. "/sessions/",
                auto_session_root_dir = vim.fn.stdpath "data" .. "/sessions/",
                auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
                post_restore_cmds = { "NvimTreeFindFile" },
                pre_save_cmds = { "NvimTreeClose" },
                log_level = 'warn',
                auto_session_enabled = true
            })
        end
    },
}
