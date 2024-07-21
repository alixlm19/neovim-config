return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- lsp zero config
        local lsp_zero = require('lsp-zero')

        lsp_zero.extend_lspconfig()

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local keymap = vim.keymap -- for conciseness

        -- local opts = { noremap = true, silent = true }
        local on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, remap = false }

            keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
            keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
            keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
            keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
            keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
            keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
            keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
            keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
            keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
            keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        end

        -- used to enable autocompletion (assign to every lsp server config)
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        -- (not in youtube nvim video)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- configure html server
        lspconfig["html"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        -- configure typescript server with plugin
        lspconfig["tsserver"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        -- configure css server
        lspconfig["cssls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = 'ignore',
                    },
                },
            },
        })

        -- configure tailwindcss server
        lspconfig["tailwindcss"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        -- configure prisma orm server
        lspconfig["prismals"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        -- configure emmet language server
        lspconfig["emmet_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
        })

        -- configure python server
        lspconfig["pyright"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = { -- custom settings for lua
                Lua = {
                    -- make the language server recognize "vim" global
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        -- make language server aware of runtime files
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                },
            },
        })
    end,
}
