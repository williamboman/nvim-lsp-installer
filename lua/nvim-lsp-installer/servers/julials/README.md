# julials

## Configuring the Julia Environment

The Julia Environment will be identified in the following order:

1) user configuration (`lspconfig.julials.setup { julia_env_path = "/my/env" }`)
2) existence of `Project.toml` & `Manifest.toml` (or `JuliaProject.toml` & `JuliaManifest.toml`) in the current project working directory
3) inferred from `Pkg.Types.Context().env.project_file`
4) inferred from `Base.current_project(pwd())`
5) inferred from `Base.load_path_expand("@v#.#)`
