local server = require("nvim-lsp-installer.server")
local path = require("nvim-lsp-installer.path")
local npm = require("nvim-lsp-installer.installers.npm")

return function(name, root_dir)
	return server.Server:new({
		name = name,
		root_dir = root_dir,
		homepage = "https://github.com/FoamScience/foam-language-server",
		languages = { "foam", "OpenFOAM" },
		installer = npm.packages({ "foam-language-server" }),
		default_options = {
			--cmd_env = npm.env(root_dir),
			cmd = { path.concat({ root_dir, "node_modules", "foam-language-server", "bin", "foam-ls" }), "--stdio" },
		},
	})
end
