# ff

`ff` is a small Bash command-line utility for creating files and directories
quickly. It supports Linux, macOS, WSL, and Windows environments with Bash
(such as Git Bash).

## Requirements

- Bash
- `mkdir`, `touch`, and `install` (typically available on Unix-like systems and
  in Git Bash/WSL)
- `curl` or `wget` for direct download

## Install

### Download with curl

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/SmarterOps/ff/main/ff \
  -o "$HOME/.local/bin/ff"
chmod +x "$HOME/.local/bin/ff"
```

### Download with wget

```bash
mkdir -p "$HOME/.local/bin"
wget -O "$HOME/.local/bin/ff" \
  https://raw.githubusercontent.com/SmarterOps/ff/main/ff
chmod +x "$HOME/.local/bin/ff"
```

Make sure `$HOME/.local/bin` is on your `PATH`. For the current Bash session:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

To add it permanently, put that line in `~/.bashrc` (Bash) or `~/.zshrc`
(Zsh), then open a new terminal. Verify the installation:

```bash
ff --help
```

Alternatively, clone the repository and run its installer:

```bash
git clone https://github.com/SmarterOps/ff.git
cd ff
bash install.sh
```

The installer uses `/usr/local/bin` when writable and falls back to
`$HOME/.local/bin`. To choose an install directory explicitly:

```bash
FF_INSTALL_DIR="$HOME/.local/bin" bash install.sh
```

## Usage

```bash
ff my-folder
ff project/main.tf
ff docs/api/v1/openapi.yaml
ff a.txt b/c/d.json
```

By default, a final path component containing a dot is treated as a file name;
otherwise it is treated as a directory. Use `--file` or `--dir` to override
that heuristic:

```bash
ff --dir release.v1
ff --file .env
```

Each type option applies to the next path only. Paths with spaces should be
quoted, for example `ff "my project/notes.txt"`.

## Output colors

On an interactive color-capable terminal, single-level directories are green,
nested directory paths are blue, and file names are yellow. For a file inside
a directory, the parent path is blue and the file name is yellow. Color is
disabled when output is redirected, `TERM=dumb`, or the `NO_COLOR` environment
variable is set. To disable it for a command:

```bash
ff --no-color project/main.tf
```

## Uninstall

Remove the installed `ff` file from the directory where it was installed. For
example:

```bash
rm "$HOME/.local/bin/ff"
```

If installed to a different location, remove that location's `ff` executable.

## Contributing

Bug reports, suggestions, and pull requests are welcome. Please include clear
steps to reproduce bugs and describe the expected behavior. Before submitting
a change, check shell syntax with:

```bash
bash -n ff install.sh
```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the contribution guidelines.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE).
