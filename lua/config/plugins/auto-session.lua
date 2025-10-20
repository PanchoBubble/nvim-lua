return {
  {
    "rmagatti/auto-session",
    config = function()
      vim.o.sessionoptions = "buffers,curdir,tabpages,localoptions"
      require("auto-session").setup {
        auto_session_last_session_dir = vim.fn.stdpath "data" .. "/sessions/",
        auto_session_root_dir = vim.fn.stdpath "data" .. "/sessions/",
        auto_session_enable_last_session = vim.loop.cwd() == vim.loop.os_homedir(),
        post_restore_cmds = { "NvimTreeFindFile" },
        pre_save_cmds = { "NvimTreeClose" },
        log_level = "warn",
        auto_session_enabled = true,
      }

      -- Add custom command to delete all sessions
      vim.api.nvim_create_user_command("SessionDeleteAll", function()
        local AutoSession = require "auto-session"
        local Lib = require "auto-session.lib"
        local session_dir = AutoSession.get_root_dir()
        local sessions = Lib.get_session_list(session_dir)

        if #sessions == 0 then
          vim.notify "No sessions found to delete"
          return
        end

        -- Ask for confirmation
        vim.ui.select({ "Yes", "No" }, {
          prompt = string.format("Delete all %d session(s)?", #sessions),
        }, function(choice)
          if choice == "Yes" then
            local deleted_count = 0
            for _, session in ipairs(sessions) do
              local session_path = session_dir .. session.file_name
              if AutoSession.DeleteSessionFile(session_path, session.display_name) then
                deleted_count = deleted_count + 1
              end
            end
            vim.notify(string.format("Deleted %d session(s)", deleted_count))
          else
            vim.notify "Session deletion cancelled"
          end
        end)
      end, {
        desc = "Delete all saved sessions",
      })
    end,
  },
}
