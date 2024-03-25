-- Lazy load all of the plugin configuration after the plugins have been loaded into the env
local pluginPath = "alix-leon.after.plugins."
local afterPath = vim.fn.stdpath('config')..'/lua/alix-leon/after/plugins'

for _, file in ipairs(vim.fn.readdir(afterPath, [[v:val =~ '\.lua$']])) do
    if file ~= 'init.lua' then
        local plugin = pluginPath..file:gsub('%.lua$', '')
        require(plugin)
    end
end
