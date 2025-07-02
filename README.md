## WRadoslaw config

### Mason Eslint problem

Sometimes ESLint doesn't know how to read the config file if it follows `.eslintrc.*` pattern.
Mason will automatically install `eslint_d` in most recent version that includes ESLint v9 that deprecates this pattern.
To verify `:!eslint_d --version`, if your version includes v9+, `:MasonInstall eslint_d@13.1.2`

Setup:

1. **_Neovim_** - code editing
2. **_Tmux_** - terminal multiplexor
3. **_Chafa_** - terminal image previewer

### LazyGit performance

1. Git config commands

```cmd
git config core.fsmonitor true
git config core.untrackedcache true
```

2. Default log order in `:LazyGitConfig<CR>`

```yml
git:
  log:
    order: default
```

3. Git maint

```cmd
git maintenance run --schedule=hourly
git maintenance run --schedule=daily
git maintenance run --schedule=weekly
git maintenance run --task=gc
```

4.Remove `--untracked-files=all` from git status

```bash
git() {
  # First, check if the command is 'git status'
  if [[ "$1" == "status" ]]; then

    # --- YOUR PROXY LOGIC STARTS HERE ---
    # Initialize an empty array to hold the filtered arguments
    filtered_args=()

    # Loop through all arguments passed to 'git status' (skipping the 'status' part itself)
    for arg in "${@:2}"; do
      # Check if the argument is '--untracked-files=all'
      if [[ "$arg" == "--untracked-files=all" ]]; then
        # If it is, skip it
        continue
      fi
      # Otherwise, add the argument to our filtered list
      filtered_args+=("$arg")
    done

    # Execute the real 'git status' command with only the filtered arguments
    command git status "${filtered_args[@]}"
    # --- YOUR PROXY LOGIC ENDS HERE ---

  else
    # For any other command (e.g., 'git pull', 'git commit'),
    # execute it normally without any changes.
    command git "$@"
  fi
}
```
