local ls = require("luasnip")

ls.add_snippets(
    "all", {
        ls.parser.parse_snippet('expand', "const [state, setState] = useState()")
    }
)
