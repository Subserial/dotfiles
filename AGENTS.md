# AGENTS.md

This document provides technical guidelines and reference documentation for AI agents working within this personal multi-host NixOS and Home Manager configuration flake.

---

## 1. Repository Architecture & Directory Structure

This repository manages Subsy's personal multi-host NixOS setups and Home Manager user environments using Nix Flakes (`x86_64-linux`).

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
│       ├── sb/            # Primary user environment (used on everfree)
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
  - `git-hooks`: Provides pre-commit validation (configured with `nixfmt`).
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
  Format all Nix files with `nixfmt` (via git-hooks pre-commit runner):
  ```bash
  nix run .#packages.x86_64-linux.pre-commit-run
  ```
  Or format specific files directly if `nixfmt` is in your environment:
  ```bash
  nixfmt flake.nix
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

## 4. Guidelines for Agents & Contributors

- **Always verify formatting**: Before finalizing changes to `.nix` files, make sure the flake builds or evaluates without syntax errors (`nix flake check`).
- **Never commit unencrypted secrets**: Never create plaintext password files or tokens outside the sops workflow. If testing a password, generate a hash using `mkpasswd -m sha-512` or test with sops.
- **Keep system and user concerns separated**:
  - System-wide hardware and service configs belong in `modules/` or `profiles/hosts/`.
  - User desktop settings, themes, and personal CLI tools belong in `profiles/users/<user>/` and `home-manager/`.
- **Maintain purity and conventions**:
  - Use `specialArgs` to pass global dependencies.
  - Ensure any new package derivations added to `./pkgs` are exposed through `pkgs/default.nix`.
