return {
    "robitx/gp.nvim",
    config = function()
        local conf = {
            providers = {
                -- openai = {
                --     endpoint = "https://api.openai.com/v1/chat/completions",
                --     secret = os.getenv("OPENAI_API_KEY"),
                -- },
                --
                -- -- azure = {...},
                --
                -- copilot = {
                --     endpoint = "https://api.githubcopilot.com/chat/completions",
                --     secret = {
                --         "bash",
                --         "-c",
                --         "cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
                --     },
                -- },
                --
                -- pplx = {
                --     endpoint = "https://api.perplexity.ai/chat/completions",
                --     secret = os.getenv("PPLX_API_KEY"),
                -- },
                --
                -- ollama = {
                --     endpoint = "http://localhost:11434/v1/chat/completions",
                -- },
                --
                googleai = {
                    endpoint =
                    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={{secret}}",
                    secret = os.getenv("GOOGLEAI_API_KEY"),
                },
                --
                -- anthropic = {
                --     endpoint = "https://api.anthropic.com/v1/messages",
                --     secret = os.getenv("ANTHROPIC_API_KEY"),
                -- },
            },
            agents = {
                {
                    provider = "googleai",
                    name = "ChatGeminiFlash",
                    chat = true,
                    command = true,
                    model = { model = "gemini-1.5-flash", temperature = 1, top_p = 1 }, -- Use the correct name here!
                    system_prompt = require("gp.defaults").chat_system_prompt,
                },
            },
        }
        require("gp").setup(conf)

        -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
}
