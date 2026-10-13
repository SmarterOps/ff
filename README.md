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

### Quick install (Linux, macOS, WSL, or Git Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/SmarterOps/ff/main/install.sh | bash
```

If `curl` is not installed, use `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/SmarterOps/ff/main/install.sh | bash
```

The installer puts `ff` in a system-wide command directory when possible. If
that is not writable, it installs to `$HOME/.local/bin` and adds that directory
to your Bash or Zsh startup files. After installation, open a new terminal and
run:

```bash
ff --help
```

If you want to use `ff` in the terminal where you installed it, run the PATH
command printed by the installer. The installer requires `curl` or `wget`; it
does not require cloning the repository.

To install from a local clone instead:

```bash
git clone https://github.com/SmarterOps/ff.git
cd ff
bash install.sh
```

The installer uses `/usr/local/bin` when writable and falls back to
`$HOME/.local/bin`. It uses `curl` or `wget` if it needs to fetch the script
from GitHub, and validates the script before replacing an existing install.
To choose an install directory explicitly:

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
otherwise it is treated as a directory. Use `--file PATH` or `--dir PATH` to
override that heuristic:

```bash
ff --dir release.v1
ff --file .env
```

Each type option takes exactly one path. Use `--` before paths that begin with
a hyphen, for example `ff -- --draft.txt`. Paths with spaces should be quoted,
for example `ff "my project/notes.txt"`. Existing files and directories are
left unchanged and reported as already existing.

## Output colors

On an interactive color-capable terminal, single-level directories are green,
nested directory paths are blue, and file names are yellow. For a file inside
a directory, the parent path is blue and the file name is yellow. Color is
disabled when output is redirected, `TERM=dumb`, or the `NO_COLOR` environment
variable is set. To force colored output when stdout is redirected, use
`--color` (unless `TERM=dumb` or `NO_COLOR` is set):

```bash
ff --color project/main.tf
```

To disable color for a command:

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
bash tests/test_ff.sh
bash tests/test_install.sh
```

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the contribution guidelines.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE).
