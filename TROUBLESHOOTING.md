# Troubleshooting

## `command not found: k380` on Linux (zsh + dotfiles)

### Symptom

On a Linux machine that shares the same dotfiles as the macOS machine, typing
`k380` fails with:

```text
zsh: command not found: k380
```

even though the keyboard is connected and this repository is checked out at
`~/IdeaProjects/k380-function-keys-conf`.

### Root cause

1. `k380` is not a real command installed in `$PATH`. In the dotfiles it is
   only defined as a zsh alias in the macOS-only fragment
   `zshrc/.zshrc.darwin`:

   ```zsh
   alias k380='sudo "$HOME/IdeaProjects/k380-function-keys-conf/k380" -f on'
   ```

2. The dotfiles source exactly one platform fragment, chosen by `$OSTYPE`
   (`zshrc/.zshrc.common`):

   ```zsh
   case "$OSTYPE" in
     darwin*) safe_source "$HOME/.zshrc.darwin" ;;
     linux*)  safe_source "$HOME/.zshrc.linux"  ;;
   esac
   ```

   On Linux (`OSTYPE=linux-gnu`) only `.zshrc.linux` is read. That file had no
   `k380` definition, so zsh never learned the command and fell back to
   `command not found`.

3. The tracked `./k380` binary in this repository is a macOS artifact
   (`Mach-O 64-bit arm64`) linked against Homebrew's `hidapi` dylib. Copying the
   alias to Linux without changing the binary would still fail with
   `Exec format error`.

### Solution

Build a native Linux binary and add a Linux-only alias.

1. Build on Linux (the committed `./k380` stays untouched):

   ```sh
   sudo pacman -S hidapi      # Arch; Debian: sudo apt install libhidapi-dev
   ./build_Linux.sh           # produces ./k380-linux (ELF x86-64)
   ```

2. Add this to `dotfiles/zshrc/.zshrc.linux`:

   ```zsh
   # Logitech K380: make the top row F1-F12. Build ./k380-linux first.
   if [[ -x "$HOME/IdeaProjects/k380-function-keys-conf/k380-linux" ]]; then
     alias k380='sudo "$HOME/IdeaProjects/k380-function-keys-conf/k380-linux" -f on'
   fi
   ```

3. Reload zsh (`exec zsh`) and verify:

   ```sh
   whence -w k380     # -> k380: alias
   k380               # sends the "F-keys on" configuration
   ```

The macOS setup is intentionally unchanged: `.zshrc.darwin` still runs the
Mach-O `./k380` binary, and `.zshrc.linux` is only sourced on Linux. A machine
therefore builds the artifact matching its own OS.

### Notes

- Root is required because the configuration is written as an HID++ report to
  `/dev/hidrawN`; `sudo` in the alias mirrors the macOS behavior. If you prefer
  not to use `sudo`, grant the active-seat user access with a udev rule, for
  example `/etc/udev/rules.d/70-k380-hidraw.rules`:

  ```udev
  KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="b342", TAG+="uaccess"
  ```

- `k380` is a zsh alias, so it only exists in interactive zsh sessions. From
  scripts or other shells, call the binary directly:

  ```sh
  sudo ~/IdeaProjects/k380-function-keys-conf/k380-linux -f on
  ```

- Unlike the macOS build, the Linux build links `hidapi-hidraw` dynamically via
  pkg-config, so there is no Homebrew dylib to keep installed and no
  `install_name_tool` / `otool` workaround needed.
