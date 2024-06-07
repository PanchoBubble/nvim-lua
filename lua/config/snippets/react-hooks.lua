local ls = require("luasnip")
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local s = ls.snippet

local function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

local formatSetState = function(args)
    local state = args[1][1]
    return ', set' .. firstToUpper(state)
end


ls.add_snippets(
    "all", {
        s("useS", {
            t("const ["),
            i(1, 'state'),
            f(formatSetState, { 1 }),
            t("] = useState("),
            i(2),
            t(")")
        })
    }
)

local routerName = function(args)
    return args[1][1] .. "Router.get('"
end

local exportState = function(args)
    return args[1][1] .. 'Router;'
end

ls.add_snippets(
    "typescript", {
        s("route", {
            t({ "import express from 'express';", "" }),
            i(1, 'name'),
            t({ "Router = express.Router();", '' }),
            f(routerName, { 1 }),
            i(2, 'path'),
            t({
                "', async (req, res) => {",
                "return res.status(200).json({ response: '' })",
                "});",
                "export default "
            }),
            f(exportState, { 1 }),
        }),
        s("forof", {
            t({ "for (const " }),
            i(1, 'var'),
            t({ " of " }),
            i(2, 'list'),
            t({ ") {", "", "}" }),
        })
    }
)
