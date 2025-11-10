# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ALE** (Asynchronous Lint Engine) is a Vim/Neovim plugin that provides:
- Real-time linting and syntax checking while you type
- Asynchronous code fixing with `:ALEFix` command
- Language Server Protocol (LSP) client functionality
- Zero dependencies for the core plugin
- Support for 158+ languages and 400+ linting/fixing tools

## Core Commands

### Running Tests

All tests use Docker. The `run-tests` script is the main entry point:

```bash
# Run all tests (Vim 8.0, Vim 9.0, Neovim 0.7, Neovim 0.8, Lua, Vint)
./run-tests

# Run tests for a specific file
./run-tests test/linter/test_eslint.vader

# Run only Neovim 0.8 tests (fastest option)
./run-tests --neovim-08-only

# Run only Lua tests
./run-tests --lua-only

# Run only linters (Vint and custom checks)
./run-tests --linters-only

# Run fast subset (Neovim 0.8 only)
./run-tests --fast

# Verbose output
./run-tests -v

# Quiet mode (only shows failures)
./run-tests -q
```

### Code Quality

```bash
# Lint VimScript with Vint
test/script/run-vint

# Run custom checks (linting rules, table checks, etc.)
test/script/custom-checks

# Check documentation tables and references
test/script/check-supported-tools-tables
test/script/check-tag-references
test/script/check-tag-alignment
test/script/check-toc
test/script/check-duplicate-tags
```

### Common Development Tasks

```bash
# Run tests for a specific language
./run-tests test/linter/test_javascript.vader

# Run tests for a specific fixer
./run-tests test/fixer/test_prettier.vader

# Run handler tests
./run-tests test/handler/

# Run completion tests
./run-tests test/completion/

# Run fix operation tests
./run-tests test/fix/
```

## Architecture Overview

### Directory Structure

- **`plugin/ale.vim`**: Plugin initialization, user commands (`:ALELint`, `:ALEFix`, etc.)
- **`autoload/ale.vim`**: Core linting orchestration logic
- **`autoload/ale/engine.vim`**: Job management and asynchronous execution
- **`autoload/ale/linter.vim`**: Linter registration and loading system
- **`autoload/ale/fix.vim`**: Code fixing orchestration
- **`autoload/ale/lsp.vim`**: Language Server Protocol client (27K lines)
- **`autoload/ale/`**: Feature modules (completion, hover, definitions, references, etc.)
- **`ale_linters/`**: 474 linter definitions organized by language (158+ languages)
- **`autoload/ale/fixers/`**: 146 fixer implementations
- **`doc/ale.txt`**: Main documentation (5,409 lines)
- **`lua/ale/`**: Neovim-specific Lua code (diagnostics API integration)
- **`test/`**: Test suites using Vader framework

### Key Architectural Patterns

1. **Lazy Loading**: Linters and LSP connections are loaded on-demand
2. **Asynchronous Execution**: Uses Vim/Neovim job control and timers (default debounce: 200ms)
3. **Modular Design**: Each linter/fixer is a separate file with simple interface
4. **Configuration-Driven**: All behavior controlled via `g:ale_*` and `b:ale_*` variables
5. **Event-Driven**: Autocommands trigger on buffer events; custom events: `ALELintPre`, `ALELintPost`, `ALEJobStarted`, `ALEFixPre`, `ALEFixPost`
6. **Zero Core Dependencies**: Optional external tools only needed for specific languages

### Adding a New Linter

Linters are defined in `ale_linters/[language]/[linter_name].vim`. Basic structure:

```vim
call ale#linter#Define(filetype, {
\   'name': 'linter_name',
\   'executable': 'tool_name',
\   'command': 'tool_name args',
\   'callback': 'ale#handlers#unix#HandleUnitXOutput',
\   'output_stream': 'stdout',
\})
```

See existing linters (e.g., `ale_linters/javascript/eslint.vim`) for complete examples.

### Adding a New Fixer

Fixers are defined in `autoload/ale/fixers/[fixer_name].vim`. Basic structure:

```vim
function! ale#fixers#my_fixer#Fix(buffer) abort
    return {
    \   'command': 'tool_name %t',
    \   'read_temporary_file': 1,
    \}
endfunction
```

## Testing Guidelines

### Test Files Organization

- **Linter tests**: `test/linter/test_[language]_[linter].vader`
- **Fixer tests**: `test/fixer/test_[fixer].vader`
- **Handler tests**: `test/handler/test_[handler].vader`
- **Completion tests**: `test/completion/`
- **Fix operation tests**: `test/fix/`
- **LSP tests**: `test/lsp/`
- **Sign/UI tests**: `test/sign/`, `test/sign_tests/`, etc.

### Vader Testing Framework

ALE uses Vader for testing. Common Vader syntax:

```vim
Execute (describe test)
  call AssertEqual(actual, expected)
  call AssertNotEqual(actual, expected)
  call AssertThrows(command)

Execute (setup)
  " Setup code here

Expect
  " Expected output here
```

## LSP Integration

The LSP client implementation spans multiple files:

- **`autoload/ale/lsp.vim`**: Core LSP protocol (JSON-RPC 2.0)
- **`autoload/ale/lsp_linter.vim`**: LSP integration for linting
- **`autoload/ale/handlers/`**: Response handlers for different LSP requests
- **`lua/ale/diagnostics.lua`**: Neovim diagnostics API integration

Key LSP features:
- Connection pooling and lifecycle management
- Document synchronization
- Capability negotiation
- Request/response tracking

## Documentation

- **Main docs**: `doc/ale.txt` (help file format)
- **Language-specific docs**: `doc/ale-[language].txt` (150+ files)
- **Supported tools list**: `supported-tools.md` (400+ tools)
- **README**: `README.md` (usage, installation, configuration)

When adding new linters/fixers:
1. Document the tool in the appropriate `doc/ale-[language].txt`
2. Add entry to `supported-tools.md`
3. Update `doc/ale.txt` if adding new features or global options

## Version Support

- **Vim**: 8.0+ required (needs job control, channels, timers)
- **Neovim**: 0.7.0+ (0.8+ for better LSP integration)
- **Docker testing**: Vim 8.0, Vim 9.0, Neovim 0.7, Neovim 0.8
- **Lua support**: Tests run with Lua 5.1

## Important Notes

### Zero-Dependency Philosophy

ALE intentionally has zero dependencies. All functionality is built in VimScript/Lua. External tools (linters, fixers, language servers) are optional and only used when configured.

### Backward Compatibility

Breaking changes are extremely rare. Always consider compatibility with older Vim/Neovim versions when making changes.

### Performance Considerations

- Linting is debounced (default 200ms) to avoid excessive execution
- Job results are processed asynchronously
- Executable detection is cached
- Virtual text and signs are rendered efficiently

### Configuration Variables Naming Convention

- `g:ale_*` - Global configuration (used as defaults)
- `b:ale_*` - Buffer-local configuration (overrides global)
- `l:ale_*` - Local variables in functions

### Common Integration Points

- **Neovim 0.8+ LSP**: ALE automatically integrates with nvim-lspconfig
- **vim-airline**: Built-in support via `g:airline#extensions#ale#enabled`
- **Deoplete**: ALE can be used as completion source
- **coc.nvim**: Can bridge diagnostics to ALE via `diagnostic.displayByAle`

## Pre-commit Considerations

The test scripts and linters will run in CI. Key things to verify before committing:

- All affected Vader tests pass
- Vint linting passes
- Custom checks pass (especially for documentation tables)
- No new linters/fixers without corresponding documentation
- Supported tools list is up to date

## Repository Status

- **Active project** with regular maintenance
- **Community-driven** with many contributors
- **Well-documented** with comprehensive help files
- **Heavily tested** with 300+ test suites
- **Stable API** - breaking changes are rare
