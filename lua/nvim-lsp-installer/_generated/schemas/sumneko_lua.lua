-- THIS FILE IS GENERATED. DO NOT EDIT MANUALLY.
-- stylua: ignore start
return {properties = {["Lua.completion.autoRequire"] = {default = true,markdownDescription = "%config.completion.autoRequire%",scope = "resource",type = "boolean"},["Lua.completion.callSnippet"] = {default = "Disable",enum = { "Disable", "Both", "Replace" },markdownDescription = "%config.completion.callSnippet%",markdownEnumDescriptions = { "%config.completion.callSnippet.Disable%", "%config.completion.callSnippet.Both%", "%config.completion.callSnippet.Replace%" },scope = "resource",type = "string"},["Lua.completion.displayContext"] = {default = 0,markdownDescription = "%config.completion.displayContext%",scope = "resource",type = "integer"},["Lua.completion.enable"] = {default = true,markdownDescription = "%config.completion.enable%",scope = "resource",type = "boolean"},["Lua.completion.keywordSnippet"] = {default = "Replace",enum = { "Disable", "Both", "Replace" },markdownDescription = "%config.completion.keywordSnippet%",markdownEnumDescriptions = { "%config.completion.keywordSnippet.Disable%", "%config.completion.keywordSnippet.Both%", "%config.completion.keywordSnippet.Replace%" },scope = "resource",type = "string"},["Lua.completion.postfix"] = {default = "@",markdownDescription = "%config.completion.postfix%",scope = "resource",type = "string"},["Lua.completion.requireSeparator"] = {default = ".",markdownDescription = "%config.completion.requireSeparator%",scope = "resource",type = "string"},["Lua.completion.showParams"] = {default = true,markdownDescription = "%config.completion.showParams%",scope = "resource",type = "boolean"},["Lua.completion.showWord"] = {default = "Fallback",enum = { "Enable", "Fallback", "Disable" },markdownDescription = "%config.completion.showWord%",markdownEnumDescriptions = { "%config.completion.showWord.Enable%", "%config.completion.showWord.Fallback%", "%config.completion.showWord.Disable%" },scope = "resource",type = "string"},["Lua.completion.workspaceWord"] = {default = true,markdownDescription = "%config.completion.workspaceWord%",scope = "resource",type = "boolean"},["Lua.diagnostics.disable"] = {default = {},items = {type = "string"},markdownDescription = "%config.diagnostics.disable%",scope = "resource",type = "array"},["Lua.diagnostics.disableScheme"] = {default = { "git" },items = {type = "string"},markdownDescription = "%config.diagnostics.disableScheme%",scope = "resource",type = "array"},["Lua.diagnostics.enable"] = {default = true,markdownDescription = "%config.diagnostics.enable%",scope = "resource",type = "boolean"},["Lua.diagnostics.globals"] = {default = {},items = {type = "string"},markdownDescription = "%config.diagnostics.globals%",scope = "resource",type = "array"},["Lua.diagnostics.ignoredFiles"] = {default = "Opened",enum = { "Enable", "Opened", "Disable" },markdownDescription = "%config.diagnostics.ignoredFiles%",markdownEnumDescriptions = { "%config.diagnostics.ignoredFiles.Enable%", "%config.diagnostics.ignoredFiles.Opened%", "%config.diagnostics.ignoredFiles.Disable%" },scope = "resource",type = "string"},["Lua.diagnostics.libraryFiles"] = {default = "Opened",enum = { "Enable", "Opened", "Disable" },markdownDescription = "%config.diagnostics.libraryFiles%",markdownEnumDescriptions = { "%config.diagnostics.libraryFiles.Enable%", "%config.diagnostics.libraryFiles.Opened%", "%config.diagnostics.libraryFiles.Disable%" },scope = "resource",type = "string"},["Lua.diagnostics.neededFileStatus"] = {additionalProperties = false,markdownDescription = "%config.diagnostics.neededFileStatus%",properties = {["ambiguity-1"] = {default = "Any",description = "%config.diagnostics.ambiguity-1%",enum = { "Any", "Opened", "None" },type = "string"},["await-in-sync"] = {default = "None",description = "%config.diagnostics.await-in-sync%",enum = { "Any", "Opened", "None" },type = "string"},["circle-doc-class"] = {default = "Any",description = "%config.diagnostics.circle-doc-class%",enum = { "Any", "Opened", "None" },type = "string"},["close-non-object"] = {default = "Any",description = "%config.diagnostics.close-non-object%",enum = { "Any", "Opened", "None" },type = "string"},["code-after-break"] = {default = "Opened",description = "%config.diagnostics.code-after-break%",enum = { "Any", "Opened", "None" },type = "string"},["codestyle-check"] = {default = "None",description = "%config.diagnostics.codestyle-check%",enum = { "Any", "Opened", "None" },type = "string"},["count-down-loop"] = {default = "Any",description = "%config.diagnostics.count-down-loop%",enum = { "Any", "Opened", "None" },type = "string"},deprecated = {default = "Opened",description = "%config.diagnostics.deprecated%",enum = { "Any", "Opened", "None" },type = "string"},["different-requires"] = {default = "Any",description = "%config.diagnostics.different-requires%",enum = { "Any", "Opened", "None" },type = "string"},["discard-returns"] = {default = "Opened",description = "%config.diagnostics.discard-returns%",enum = { "Any", "Opened", "None" },type = "string"},["doc-field-no-class"] = {default = "Any",description = "%config.diagnostics.doc-field-no-class%",enum = { "Any", "Opened", "None" },type = "string"},["duplicate-doc-alias"] = {default = "Any",description = "%config.diagnostics.duplicate-doc-alias%",enum = { "Any", "Opened", "None" },type = "string"},["duplicate-doc-field"] = {default = "Any",description = "%config.diagnostics.duplicate-doc-field%",enum = { "Any", "Opened", "None" },type = "string"},["duplicate-doc-param"] = {default = "Any",description = "%config.diagnostics.duplicate-doc-param%",enum = { "Any", "Opened", "None" },type = "string"},["duplicate-index"] = {default = "Any",description = "%config.diagnostics.duplicate-index%",enum = { "Any", "Opened", "None" },type = "string"},["duplicate-set-field"] = {default = "Any",description = "%config.diagnostics.duplicate-set-field%",enum = { "Any", "Opened", "None" },type = "string"},["empty-block"] = {default = "Opened",description = "%config.diagnostics.empty-block%",enum = { "Any", "Opened", "None" },type = "string"},["global-in-nil-env"] = {default = "Any",description = "%config.diagnostics.global-in-nil-env%",enum = { "Any", "Opened", "None" },type = "string"},["lowercase-global"] = {default = "Any",description = "%config.diagnostics.lowercase-global%",enum = { "Any", "Opened", "None" },type = "string"},["missing-parameter"] = {default = "Opened",description = "%config.diagnostics.missing-parameter%",enum = { "Any", "Opened", "None" },type = "string"},["need-check-nil"] = {default = "Opened",description = "%config.diagnostics.need-check-nil%",enum = { "Any", "Opened", "None" },type = "string"},["newfield-call"] = {default = "Any",description = "%config.diagnostics.newfield-call%",enum = { "Any", "Opened", "None" },type = "string"},["newline-call"] = {default = "Any",description = "%config.diagnostics.newline-call%",enum = { "Any", "Opened", "None" },type = "string"},["no-unknown"] = {default = "None",description = "%config.diagnostics.no-unknown%",enum = { "Any", "Opened", "None" },type = "string"},["not-yieldable"] = {default = "None",description = "%config.diagnostics.not-yieldable%",enum = { "Any", "Opened", "None" },type = "string"},["redefined-local"] = {default = "Opened",description = "%config.diagnostics.redefined-local%",enum = { "Any", "Opened", "None" },type = "string"},["redundant-parameter"] = {default = "Opened",description = "%config.diagnostics.redundant-parameter%",enum = { "Any", "Opened", "None" },type = "string"},["redundant-return"] = {default = "Opened",description = "%config.diagnostics.redundant-return%",enum = { "Any", "Opened", "None" },type = "string"},["redundant-value"] = {default = "Opened",description = "%config.diagnostics.redundant-value%",enum = { "Any", "Opened", "None" },type = "string"},["spell-check"] = {default = "None",description = "%config.diagnostics.spell-check%",enum = { "Any", "Opened", "None" },type = "string"},["trailing-space"] = {default = "Opened",description = "%config.diagnostics.trailing-space%",enum = { "Any", "Opened", "None" },type = "string"},["type-check"] = {default = "None",description = "%config.diagnostics.type-check%",enum = { "Any", "Opened", "None" },type = "string"},["unbalanced-assignments"] = {default = "Any",description = "%config.diagnostics.unbalanced-assignments%",enum = { "Any", "Opened", "None" },type = "string"},["undefined-doc-class"] = {default = "Any",description = "%config.diagnostics.undefined-doc-class%",enum = { "Any", "Opened", "None" },type = "string"},["undefined-doc-name"] = {default = "Any",description = "%config.diagnostics.undefined-doc-name%",enum = { "Any", "Opened", "None" },type = "string"},["undefined-doc-param"] = {default = "Any",description = "%config.diagnostics.undefined-doc-param%",enum = { "Any", "Opened", "None" },type = "string"},["undefined-env-child"] = {default = "Any",description = "%config.diagnostics.undefined-env-child%",enum = { "Any", "Opened", "None" },type = "string"},["undefined-field"] = {default = "Opened",description = "%config.diagnostics.undefined-field%",enum = { "Any", "Opened", "None" },type = "string"},["undefined-global"] = {default = "Any",description = "%config.diagnostics.undefined-global%",enum = { "Any", "Opened", "None" },type = "string"},["unknown-diag-code"] = {default = "Any",description = "%config.diagnostics.unknown-diag-code%",enum = { "Any", "Opened", "None" },type = "string"},["unused-function"] = {default = "Opened",description = "%config.diagnostics.unused-function%",enum = { "Any", "Opened", "None" },type = "string"},["unused-label"] = {default = "Opened",description = "%config.diagnostics.unused-label%",enum = { "Any", "Opened", "None" },type = "string"},["unused-local"] = {default = "Opened",description = "%config.diagnostics.unused-local%",enum = { "Any", "Opened", "None" },type = "string"},["unused-vararg"] = {default = "Opened",description = "%config.diagnostics.unused-vararg%",enum = { "Any", "Opened", "None" },type = "string"}},scope = "resource",title = "neededFileStatus",type = "object"},["Lua.diagnostics.severity"] = {additionalProperties = false,markdownDescription = "%config.diagnostics.severity%",properties = {["ambiguity-1"] = {default = "Warning",description = "%config.diagnostics.ambiguity-1%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["await-in-sync"] = {default = "Warning",description = "%config.diagnostics.await-in-sync%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["circle-doc-class"] = {default = "Warning",description = "%config.diagnostics.circle-doc-class%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["close-non-object"] = {default = "Warning",description = "%config.diagnostics.close-non-object%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["code-after-break"] = {default = "Hint",description = "%config.diagnostics.code-after-break%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["codestyle-check"] = {default = "Warning",description = "%config.diagnostics.codestyle-check%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["count-down-loop"] = {default = "Warning",description = "%config.diagnostics.count-down-loop%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},deprecated = {default = "Warning",description = "%config.diagnostics.deprecated%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["different-requires"] = {default = "Warning",description = "%config.diagnostics.different-requires%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["discard-returns"] = {default = "Warning",description = "%config.diagnostics.discard-returns%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["doc-field-no-class"] = {default = "Warning",description = "%config.diagnostics.doc-field-no-class%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["duplicate-doc-alias"] = {default = "Warning",description = "%config.diagnostics.duplicate-doc-alias%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["duplicate-doc-field"] = {default = "Warning",description = "%config.diagnostics.duplicate-doc-field%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["duplicate-doc-param"] = {default = "Warning",description = "%config.diagnostics.duplicate-doc-param%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["duplicate-index"] = {default = "Warning",description = "%config.diagnostics.duplicate-index%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["duplicate-set-field"] = {default = "Warning",description = "%config.diagnostics.duplicate-set-field%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["empty-block"] = {default = "Hint",description = "%config.diagnostics.empty-block%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["global-in-nil-env"] = {default = "Warning",description = "%config.diagnostics.global-in-nil-env%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["lowercase-global"] = {default = "Information",description = "%config.diagnostics.lowercase-global%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["missing-parameter"] = {default = "Warning",description = "%config.diagnostics.missing-parameter%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["need-check-nil"] = {default = "Warning",description = "%config.diagnostics.need-check-nil%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["newfield-call"] = {default = "Warning",description = "%config.diagnostics.newfield-call%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["newline-call"] = {default = "Information",description = "%config.diagnostics.newline-call%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["no-unknown"] = {default = "Information",description = "%config.diagnostics.no-unknown%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["not-yieldable"] = {default = "Warning",description = "%config.diagnostics.not-yieldable%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["redefined-local"] = {default = "Hint",description = "%config.diagnostics.redefined-local%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["redundant-parameter"] = {default = "Warning",description = "%config.diagnostics.redundant-parameter%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["redundant-return"] = {default = "Warning",description = "%config.diagnostics.redundant-return%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["redundant-value"] = {default = "Warning",description = "%config.diagnostics.redundant-value%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["spell-check"] = {default = "Information",description = "%config.diagnostics.spell-check%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["trailing-space"] = {default = "Hint",description = "%config.diagnostics.trailing-space%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["type-check"] = {default = "Warning",description = "%config.diagnostics.type-check%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["unbalanced-assignments"] = {default = "Warning",description = "%config.diagnostics.unbalanced-assignments%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["undefined-doc-class"] = {default = "Warning",description = "%config.diagnostics.undefined-doc-class%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["undefined-doc-name"] = {default = "Warning",description = "%config.diagnostics.undefined-doc-name%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["undefined-doc-param"] = {default = "Warning",description = "%config.diagnostics.undefined-doc-param%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["undefined-env-child"] = {default = "Information",description = "%config.diagnostics.undefined-env-child%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["undefined-field"] = {default = "Warning",description = "%config.diagnostics.undefined-field%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["undefined-global"] = {default = "Warning",description = "%config.diagnostics.undefined-global%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["unknown-diag-code"] = {default = "Warning",description = "%config.diagnostics.unknown-diag-code%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["unused-function"] = {default = "Hint",description = "%config.diagnostics.unused-function%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["unused-label"] = {default = "Hint",description = "%config.diagnostics.unused-label%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["unused-local"] = {default = "Hint",description = "%config.diagnostics.unused-local%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"},["unused-vararg"] = {default = "Hint",description = "%config.diagnostics.unused-vararg%",enum = { "Error", "Warning", "Information", "Hint" },type = "string"}},scope = "resource",title = "severity",type = "object"},["Lua.diagnostics.workspaceDelay"] = {default = 3000,markdownDescription = "%config.diagnostics.workspaceDelay%",scope = "resource",type = "integer"},["Lua.diagnostics.workspaceRate"] = {default = 100,markdownDescription = "%config.diagnostics.workspaceRate%",scope = "resource",type = "integer"},["Lua.format.defaultConfig"] = {additionalProperties = false,default = {},markdownDescription = "%config.format.defaultConfig%",patternProperties = {[".*"] = {default = "",type = "string"}},scope = "resource",title = "defaultConfig",type = "object"},["Lua.format.enable"] = {default = true,markdownDescription = "%config.format.enable%",scope = "resource",type = "boolean"},["Lua.hint.arrayIndex"] = {default = "Auto",enum = { "Enable", "Auto", "Disable" },markdownDescription = "%config.hint.arrayIndex%",markdownEnumDescriptions = { "%config.hint.arrayIndex.Enable%", "%config.hint.arrayIndex.Auto%", "%config.hint.arrayIndex.Disable%" },scope = "resource",type = "string"},["Lua.hint.await"] = {default = true,markdownDescription = "%config.hint.await%",scope = "resource",type = "boolean"},["Lua.hint.enable"] = {default = false,markdownDescription = "%config.hint.enable%",scope = "resource",type = "boolean"},["Lua.hint.paramName"] = {default = "All",enum = { "All", "Literal", "Disable" },markdownDescription = "%config.hint.paramName%",markdownEnumDescriptions = { "%config.hint.paramName.All%", "%config.hint.paramName.Literal%", "%config.hint.paramName.Disable%" },scope = "resource",type = "string"},["Lua.hint.paramType"] = {default = true,markdownDescription = "%config.hint.paramType%",scope = "resource",type = "boolean"},["Lua.hint.setType"] = {default = false,markdownDescription = "%config.hint.setType%",scope = "resource",type = "boolean"},["Lua.hover.enable"] = {default = true,markdownDescription = "%config.hover.enable%",scope = "resource",type = "boolean"},["Lua.hover.enumsLimit"] = {default = 5,markdownDescription = "%config.hover.enumsLimit%",scope = "resource",type = "integer"},["Lua.hover.expandAlias"] = {default = true,markdownDescription = "%config.hover.expandAlias%",scope = "resource",type = "boolean"},["Lua.hover.previewFields"] = {default = 20,markdownDescription = "%config.hover.previewFields%",scope = "resource",type = "integer"},["Lua.hover.viewNumber"] = {default = true,markdownDescription = "%config.hover.viewNumber%",scope = "resource",type = "boolean"},["Lua.hover.viewString"] = {default = true,markdownDescription = "%config.hover.viewString%",scope = "resource",type = "boolean"},["Lua.hover.viewStringMax"] = {default = 1000,markdownDescription = "%config.hover.viewStringMax%",scope = "resource",type = "integer"},["Lua.misc.parameters"] = {default = {},items = {type = "string"},markdownDescription = "%config.misc.parameters%",scope = "resource",type = "array"},["Lua.runtime.builtin"] = {additionalProperties = false,markdownDescription = "%config.runtime.builtin%",properties = {basic = {default = "default",description = "%config.runtime.builtin.basic%",enum = { "default", "enable", "disable" },type = "string"},bit = {default = "default",description = "%config.runtime.builtin.bit%",enum = { "default", "enable", "disable" },type = "string"},bit32 = {default = "default",description = "%config.runtime.builtin.bit32%",enum = { "default", "enable", "disable" },type = "string"},builtin = {default = "default",description = "%config.runtime.builtin.builtin%",enum = { "default", "enable", "disable" },type = "string"},coroutine = {default = "default",description = "%config.runtime.builtin.coroutine%",enum = { "default", "enable", "disable" },type = "string"},debug = {default = "default",description = "%config.runtime.builtin.debug%",enum = { "default", "enable", "disable" },type = "string"},ffi = {default = "default",description = "%config.runtime.builtin.ffi%",enum = { "default", "enable", "disable" },type = "string"},io = {default = "default",description = "%config.runtime.builtin.io%",enum = { "default", "enable", "disable" },type = "string"},jit = {default = "default",description = "%config.runtime.builtin.jit%",enum = { "default", "enable", "disable" },type = "string"},math = {default = "default",description = "%config.runtime.builtin.math%",enum = { "default", "enable", "disable" },type = "string"},os = {default = "default",description = "%config.runtime.builtin.os%",enum = { "default", "enable", "disable" },type = "string"},package = {default = "default",description = "%config.runtime.builtin.package%",enum = { "default", "enable", "disable" },type = "string"},string = {default = "default",description = "%config.runtime.builtin.string%",enum = { "default", "enable", "disable" },type = "string"},table = {default = "default",description = "%config.runtime.builtin.table%",enum = { "default", "enable", "disable" },type = "string"},utf8 = {default = "default",description = "%config.runtime.builtin.utf8%",enum = { "default", "enable", "disable" },type = "string"}},scope = "resource",title = "builtin",type = "object"},["Lua.runtime.fileEncoding"] = {default = "utf8",enum = { "utf8", "ansi", "utf16le", "utf16be" },markdownDescription = "%config.runtime.fileEncoding%",markdownEnumDescriptions = { "%config.runtime.fileEncoding.utf8%", "%config.runtime.fileEncoding.ansi%", "%config.runtime.fileEncoding.utf16le%", "%config.runtime.fileEncoding.utf16be%" },scope = "resource",type = "string"},["Lua.runtime.meta"] = {default = "${version} ${language} ${encoding}",markdownDescription = "%config.runtime.meta%",scope = "resource",type = "string"},["Lua.runtime.nonstandardSymbol"] = {default = {},items = {enum = { "//", "/**/", "`", "+=", "-=", "*=", "/=", "||", "&&", "!", "!=", "continue" },type = "string"},markdownDescription = "%config.runtime.nonstandardSymbol%",scope = "resource",type = "array"},["Lua.runtime.path"] = {default = { "?.lua", "?/init.lua" },items = {type = "string"},markdownDescription = "%config.runtime.path%",scope = "resource",type = "array"},["Lua.runtime.pathStrict"] = {default = false,markdownDescription = "%config.runtime.pathStrict%",scope = "resource",type = "boolean"},["Lua.runtime.plugin"] = {default = "",markdownDescription = "%config.runtime.plugin%",scope = "resource",type = "string"},["Lua.runtime.special"] = {additionalProperties = false,default = {},markdownDescription = "%config.runtime.special%",patternProperties = {[".*"] = {default = "require",enum = { "_G", "rawset", "rawget", "setmetatable", "require", "dofile", "loadfile", "pcall", "xpcall", "assert", "error", "type" },type = "string"}},scope = "resource",title = "special",type = "object"},["Lua.runtime.unicodeName"] = {default = false,markdownDescription = "%config.runtime.unicodeName%",scope = "resource",type = "boolean"},["Lua.runtime.version"] = {default = "Lua 5.4",enum = { "Lua 5.1", "Lua 5.2", "Lua 5.3", "Lua 5.4", "LuaJIT" },markdownDescription = "%config.runtime.version%",markdownEnumDescriptions = { "%config.runtime.version.Lua 5.1%", "%config.runtime.version.Lua 5.2%", "%config.runtime.version.Lua 5.3%", "%config.runtime.version.Lua 5.4%", "%config.runtime.version.LuaJIT%" },scope = "resource",type = "string"},["Lua.semantic.annotation"] = {default = true,markdownDescription = "%config.semantic.annotation%",scope = "resource",type = "boolean"},["Lua.semantic.enable"] = {default = true,markdownDescription = "%config.semantic.enable%",scope = "resource",type = "boolean"},["Lua.semantic.keyword"] = {default = false,markdownDescription = "%config.semantic.keyword%",scope = "resource",type = "boolean"},["Lua.semantic.variable"] = {default = true,markdownDescription = "%config.semantic.variable%",scope = "resource",type = "boolean"},["Lua.signatureHelp.enable"] = {default = true,markdownDescription = "%config.signatureHelp.enable%",scope = "resource",type = "boolean"},["Lua.spell.dict"] = {default = {},items = {type = "string"},markdownDescription = "%config.spell.dict%",scope = "resource",type = "array"},["Lua.telemetry.enable"] = {default = vim.NIL,markdownDescription = "%config.telemetry.enable%",scope = "resource",tags = { "telemetry" },type = { "boolean", "null" }},["Lua.window.progressBar"] = {default = true,markdownDescription = "%config.window.progressBar%",scope = "resource",type = "boolean"},["Lua.window.statusBar"] = {default = true,markdownDescription = "%config.window.statusBar%",scope = "resource",type = "boolean"},["Lua.workspace.checkThirdParty"] = {default = true,markdownDescription = "%config.workspace.checkThirdParty%",scope = "resource",type = "boolean"},["Lua.workspace.ignoreDir"] = {default = { ".vscode" },items = {type = "string"},markdownDescription = "%config.workspace.ignoreDir%",scope = "resource",type = "array"},["Lua.workspace.ignoreSubmodules"] = {default = true,markdownDescription = "%config.workspace.ignoreSubmodules%",scope = "resource",type = "boolean"},["Lua.workspace.library"] = {default = {},items = {type = "string"},markdownDescription = "%config.workspace.library%",scope = "resource",type = "array"},["Lua.workspace.maxPreload"] = {default = 5000,markdownDescription = "%config.workspace.maxPreload%",scope = "resource",type = "integer"},["Lua.workspace.preloadFileSize"] = {default = 500,markdownDescription = "%config.workspace.preloadFileSize%",scope = "resource",type = "integer"},["Lua.workspace.supportScheme"] = {default = { "file", "untitled", "git" },items = {type = "string"},markdownDescription = "%config.workspace.supportScheme%",scope = "resource",type = "array"},["Lua.workspace.useGitIgnore"] = {default = true,markdownDescription = "%config.workspace.useGitIgnore%",scope = "resource",type = "boolean"},["Lua.workspace.userThirdParty"] = {default = {},items = {type = "string"},markdownDescription = "%config.workspace.userThirdParty%",scope = "resource",type = "array"}},title = "Lua",type = "object"}