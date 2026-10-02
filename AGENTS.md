# AGENTS.md

This document provides technical guidelines and reference documentation for AI agents working within this personal multi-host NixOS and Home Manager configuration flake.

---

## 1. Repository Architecture & Directory Structure

This repository manages a personal multi-host NixOS setups and Home Manager user environments using Nix Flakes (`x86_64-linux`).

### High-Level Directory Layout

```
.
├── flake.nix              # Top-level flake entrypoint defining inputs, nixosConfigurations, checks
├── flake.lock             # Flake lockfile pinning exact input revisions
├── flake.systems.nix      # List of supported systems (currently just "x86_64-linux")
├── .sops.yaml             # SOPS configuration mapping age public keys to secret file paths
├── profiles/
│   ├── hosts/             # NixOS machine / host profiles
│   │   ├── everfree.nix   # Framework 11th Gen Laptop (Intel i5-1135G7 + AMD Radeon RX 5700 XT eGPU)
│   │   ├── library.nix    # Dell XPS 15 9570 Laptop (Intel + Nvidia Hybrid)
│   │   └── cloudsdale.nix # Minimal bootable NixOS ISO installer with LUKS/YubiKey bootstrap tools (somewhat tested)
│   └── users/             # User environment profiles & desktop configs
│       ├── sb/            # User environment for everfree (`users.users.sb`)
│       ├── twilight/      # User environment for library (`users.users.twilight`)
│       └── rdash/         # Minimal user for cloudsdale installer (`users.users.rdash`)
├── modules/               # Custom reusable NixOS modules
├── home-manager/          # Reusable Home Manager modules
├── pkgs/                  # Custom Nix package derivations
├── scripts/               # Helper utilities & desktop scripts (e.g., lock screen, monitor, audio scripts)
└── secrets/               # SOPS-encrypted secrets
```

### Module & Flake Wiring

- **Flake Inputs**:
  - `nixpkgs`: Uses `nixos-unstable`.
  - `nixos-hardware`: Provides hardware-specific quirks (e.g., Dell XPS 15 9570, Framework 11th Gen).
  - `home-manager`: Manages user dotfiles and packages.
  - `sops-nix`: Manages secret decryption using `age` keys.
  - `git-hooks`: Provides pre-commit validation and code formatting (configured with `nixfmt` for Nix and `stylua` for Lua).
- **`specialArgs`**:
  - `self`: Reference to the flake repository.
  - `localPackages`: Custom derivations built from `./pkgs`, passed into all host configurations and available to modules and user environments.
- **User Management Conventions**:
  - `users.mutableUsers = false` is enforced on deployed machines (`everfree`, `library`). User passwords are not stored in plaintext and cannot be changed interactively outside NixOS configuration.
  - Passwords are provided via `hashedPasswordFile` pointing to decrypted sops secret paths or via password files.

---

## 2. Build & Evaluation Procedures

All commands should be executed from the repository root.

### Evaluation & Health Checks

- **Pre-commit and Flake Checks**:
  Verify flake validity, evaluate configurations, and run code formatting checks:
  ```bash
  nix flake check
  ```
- **Code Formatting**:
  Format all Nix and Lua files automatically with `nix fmt` (runs `nixfmt` for `.nix` and `stylua` for `.lua` via the git-hooks pre-commit runner):
  ```bash
  nix fmt
  ```
  Or run the pre-commit checks directly:
  ```bash
  nix run .#packages.x86_64-linux.pre-commit-run
  ```

### Building Host Configurations

To test-build a NixOS system configuration without activating it:

- **Everfree (Framework)**:
  ```bash
  nixos-rebuild build --flake .#everfree
  ```
- **Library (Dell XPS)**:
  ```bash
  nixos-rebuild build --flake .#library
  ```
- **Cloudsdale (Minimal Installer ISO)**:
  ```bash
  nix build .#nixosConfigurations.cloudsdale.config.system.build.isoImage
  ```

### Switching / Deploying

When running on the target machine with root privileges:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```
For example, on `everfree`:
```bash
sudo nixos-rebuild switch --flake .#everfree
```

To test without adding to the bootloader menu:
```bash
sudo nixos-rebuild test --flake .#everfree
```

---

## 3. Secrets Management with SOPS and Age

Secrets are encrypted using [sops-nix](https://github.com/Mic92/sops-nix) with `age` public keys. Plaintext secrets are **never** committed to version control.

### Configuration (`.sops.yaml`)

`.sops.yaml` at repository root controls encryption rules:
- **Keys**: Public `age` recipient keys are declared for each host (e.g., `&host_everfree age1...`, `&host_library age1...`).
- **Creation Rules**: Path regexes map secret files to the authorized keys:
  - `secrets/everfree/.*` is encrypted for `host_everfree`.
  - `secrets/library/.*` is encrypted for `host_library`.

### Private Key Locations on Target Systems

When a host boots, `sops-nix` looks for the private age key at:
- **`everfree`**: `/root/.sops/secrets/everfree.age` (configured via `sops.age.keyFile` in `profiles/hosts/everfree.nix`)
- **`library`**: `/root/.config/sops/age/keys.txt` (configured via `sops.age.keyFile` in `profiles/hosts/library.nix`)

### Step-by-Step: Adding or Updating a Secret

1. **Verify or create destination file in `secrets/<hostname>/`**:
   Ensure you place the secret in the folder matching the host name so `.sops.yaml` creation rules apply.
   ```bash
   # Example: Adding a password or token for everfree
   mkdir -p secrets/everfree
   ```

2. **Create / Edit the encrypted secret using `sops`**:
   Use `sops` directly. It reads `.sops.yaml` automatically to determine the recipient public key:
   ```bash
   sops secrets/everfree/my-secret.txt
   ```
   If creating from an existing plaintext file or string:
   ```bash
   # Encrypting binary or raw text:
   sops -e --in-place secrets/everfree/my-secret.txt
   ```
   *Note*: User password hashes (`hashedPasswordFile`) must be generated with `mkpasswd -m sha-512`.

3. **Declare the secret in the host NixOS configuration**:
   In the relevant host file (e.g., `profiles/hosts/everfree.nix`), declare the secret under `sops.secrets`:
   ```nix
   sops.secrets."my-secret" = {
     sopsFile = ../../secrets/everfree/my-secret.txt;
     format = "binary"; # or "yaml" / "json" depending on file format
     neededForUsers = false; # Set to true if required during user creation at boot
   };
   ```

4. **Reference the decrypted secret in modules**:
   The decrypted secret will be made available at `/run/secrets/<name>`:
   ```nix
   config.sops.secrets."my-secret".path
   ```
   Example for a user password (`neededForUsers = true` is required in this case):
   ```nix
   sops.secrets."sb-password" = {
     sopsFile = ../../secrets/everfree/password.txt;
     format = "binary";
     neededForUsers = true;
   };

   users.users.sb.hashedPasswordFile = config.sops.secrets."sb-password".path;
   ```

5. **Track encrypted files in git**:
   Once encrypted, stage the encrypted file:
   ```bash
   git add secrets/<host>/my-secret.txt
   ```

---

## 4. Desktop Configuration & Hyprland Lua Setup

For the `sb` user on `everfree`, Hyprland is configured using the modern Lua API (`hl.*`) rather than legacy `hyprlang` (`.conf`).

### Decoupled Runtime Architecture & Copy-over Behavior

- **Home Manager Entrypoint (`hyprland.lua`)**:
  Home Manager manages `~/.config/hypr/hyprland.lua` as a read-only symlink to `/nix/store/...`. It sets up compositor lifecycle hooks (e.g. systemd session targets) and imports the standalone user configuration:
  ```lua
  dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.user.lua")
  ```

- **User-Editable Configuration (`hyprland.user.lua`)**:
  The active compositor configuration resides at `~/.config/hypr/hyprland.user.lua`. It is a regular, writable file (`-rw-r--r--`), **not** a Nix store symlink. Users can edit it freely and reload Hyprland immediately with `hyprctl reload` without needing to run `nixos-rebuild switch`.

- **Automatic Seeding on Login (`seed-hyprland-config.service`)**:
  A oneshot systemd user service runs at session startup (before `graphical-session-pre.target` and `hyprland-session.target`).
  - Sourced directly from the active OS closure template in `/nix/store/...` (packaged from `profiles/users/sb/hyprland.user.lua` at build time).
  - Checks if `~/.config/hypr/hyprland.user.lua` exists; if missing, copies the template and grants user write permissions (`chmod u+w`).
  - It does **not** overwrite the file if it already exists, preserving local customizations across system rebuilds.

### How to Maintain & Update the Hyprland Configuration

1. **Local Testing & Live Tweaking**:
   - Edit `~/.config/hypr/hyprland.user.lua` directly using any editor.
   - Reload Hyprland immediately via `hyprctl reload` or the keybind `SUPER + SHIFT + R`.
   - Verify active functionality or inspect errors using `hyprctl configerrors`.

2. **Committing Changes back to the Repository**:
   - Once satisfied with changes made in `~/.config/hypr/hyprland.user.lua`, copy the updated file back to the repository:
     ```bash
     cp ~/.config/hypr/hyprland.user.lua profiles/users/sb/hyprland.user.lua
     ```
   - Format the code:
     ```bash
     nix fmt
     ```
   - Stage and commit the changes in git:
     ```bash
     git add profiles/users/sb/hyprland.user.lua
     git commit -m "Update hyprland configuration"
     ```
   - Deploy or test-build:
     ```bash
     sudo nixos-rebuild switch --flake .#everfree
     ```

---

## 5. Desktop Widgets: Eww Bar & Control Center

For user `sb` on `everfree`, custom desktop widgets are implemented using [Eww (ElKowars wacky widgets)](https://elkowar.github.io/eww/) with GTK layer-shell, styled dynamically using Pywal colors.

### Decoupled Runtime Architecture & Copy-over Behavior

- **Template Source in Repository (`profiles/users/sb/eww/`)**:
  Contains `eww.yuck`, `eww.scss`, and helper scripts in `scripts/`.
- **User-Editable Configuration (`~/.config/eww/`)**:
  The active runtime configuration is a regular, writable directory (`~/.config/eww/`), **not** a Nix store symlink. Users can edit widgets, scripts, and stylesheets freely and reload them immediately with `eww reload`.
- **Automatic Seeding on Login (`seed-eww-config.service`)**:
  A oneshot systemd user service in `profiles/users/sb/hyprland.nix` copies templates from `/nix/store/...` into `~/.config/eww/` if missing, preserving existing local customizations across system rebuilds.
- **Autostart Lifecycle**:
  The Eww daemon and background processes are launched on compositor startup in `profiles/users/sb/hyprland.user.lua`:
  - `eww daemon`
  - `~/.config/eww/scripts/open-bars.sh` (opens single bar preferring `HDMI-A-1`)
  - `~/.config/eww/scripts/event-watcher.sh` (listens to Hyprland socket2 events)

### Key Components & Conventions

1. **Taskbar (`bar_hdmi`, `bar_dp`)**:
   - Single taskbar anchored to the bottom of preferred display `HDMI-A-1`.
   - **Centered Clock**: Implemented with native `centerbox :orientation "h"`.
   - **Workspace Indicator (`<top> | <bottom>`)**:
     - Formatted by `scripts/workspaces.sh` (e.g. `2 | 9`).
     - Workspaces are strictly numbers `0` through `9` (`name:0` for workspace 0). Workspace 10 does not exist.
     - Clicking the badge enters `workspace_selector` mode (`.selector-active` Pywal amber glow); pressing `0`–`9`, `Tab`, or `` ` `` switches workspaces.
2. **Control Center Pop-up (`control_center`)**:
   - Anchored at bottom-right of the active monitor via `scripts/toggle-control-center.sh` (keybind `SUPER + space`).
   - **Click-Outside Dismissal**: Transparent full-screen layer-shell backdrop catchers (`control_center_catcher_dp`, `control_center_catcher_hdmi`) catch clicks outside the popup to dismiss it immediately.
   - **Focus Dismissal**: `scripts/event-watcher.sh` monitors Hyprland socket events (`activewindow`, `workspace`, `focusedmon`) to dismiss the pop-up on window interactions.
   - **Display Mode**: Extend vs. Mirror switching via `scripts/display-select.sh`.
   - **Smart App Focus**: `scripts/launch-or-focus.sh` queries client window addresses to shift focus to the active window and screen for Discord and Steam.
   - **Brightness & Volume**: Screen brightness slider powered by `scripts/brightness.sh` (`brightnessctl`) placed below Audio Volume.
   - **Shutdown Confirmation**: 2-step confirmation via `scripts/shutdown-action.sh`. Clicking changes label to "Exit?" with accent fill, resetting after 5 seconds or upon dialog close. *Never execute shutdown commands during agent testing.*

### How to Maintain & Update Eww Configuration

1. **Local Testing & Tweaking**:
   - Edit files in `~/.config/eww/`.
   - Reload widgets immediately:
     ```bash
     eww reload
     ```
   - Check active windows and debug logs:
     ```bash
     eww active-windows
     eww logs
     ```

2. **Committing Changes Back to the Repository**:
   - Copy updated files from `~/.config/eww/` back to the repository:
     ```bash
     cp -r ~/.config/eww/* profiles/users/sb/eww/
     ```
   - Format the code:
     ```bash
     nix fmt
     ```
   - Stage and commit in git:
     ```bash
     git add profiles/users/sb/eww/
     git commit -m "Update eww widget configuration"
     ```

---

## 6. Guidelines for Agents & Contributors

- **Always verify formatting**: Before finalizing changes to `.nix` or `.lua` files, format all files with `nix fmt` (configured via `git-hooks` with `nixfmt` and `stylua`), and make sure the flake builds or evaluates without syntax errors (`nix flake check`).
- **Never commit unencrypted secrets**: Never create plaintext password files or tokens outside the sops workflow. If testing a password, generate a hash using `mkpasswd -m sha-512` or test with sops.
- **Keep system and user concerns separated**:
  - System-wide hardware and service configs belong in `modules/` or `profiles/hosts/`.
  - User desktop settings, themes, and personal CLI tools belong in `profiles/users/<user>/` and `home-manager/`.
  - For user `sb`, Hyprland compositor settings live in `profiles/users/sb/hyprland.user.lua` (Lua), rather than in Nix `settings = { ... }`.
  - For user `sb`, Eww widgets live in `profiles/users/sb/eww/` and seed to `~/.config/eww/`.
- **Maintain purity and conventions**:
  - Use `specialArgs` to pass global dependencies.
  - Ensure any new package derivations added to `./pkgs` are exposed through `pkgs/default.nix`.

