# A simple rust CLI app template

This is a more user experience focussed CLI templated.
The used library, `clap` can be quite large but has create features,
including generation of man files and shell completions.

There are alternatives with a smaller footprint, but less features.

Check this out using `nix flake init -t github:rappet/stash#rust-cli`

This includes

- `env_logger`
- A `clap` CLI
- Automatically generated man page with clap
- Automatically generated shell completions with clap
