# OraDBA Extension Template

This repository is a ready-to-use OraDBA extension template. Copy/clone it,
rename the extension, and start adding your own scripts, SQL, and RMAN content.
CI and release workflows are included; the build script only packages the
extension payload (bin/sql/rcv/etc/lib + metadata/docs), not the dev helpers.

## Quick Start

- Clone/copy this repo.
- Rename the extension metadata: `./scripts/rename-extension.sh --name myext --description "My OraDBA add-ons"`
- Customize `bin/`, `sql/`, `rcv/`, `etc/`, and `lib/` with your logic.
- Build tarball + checksum: `./scripts/build.sh`
- Tag and push to GitHub to publish via the included release workflow.

## Structure (repo = extension)

```text
.extension                  # Extension metadata (name/version/priority/description)
README.md                   # Template overview (this file)
CHANGELOG.md, VERSION, LICENSE
bin/                        # Scripts added to PATH
sql/                        # SQL scripts added to SQLPATH
rcv/                        # RMAN scripts
etc/                        # Config examples (not auto-loaded)
lib/                        # Shared helpers
scripts/                    # Dev tooling (build/rename)
tests/                      # BATS tests for dev tooling
.github/workflows/          # CI (lint/tests) and release
dist/                       # Build outputs (ignored)
```

## Packaging

- `scripts/build.sh` reads `VERSION` and `.extension` to create `dist/<name>-<version>.tar.gz` plus `<tarball>.sha256`.
- Only extension payload is included by default (`.extension`, `.checksumignore`,
  README/CHANGELOG/LICENSE/VERSION, bin/sql/rcv/etc/lib). Dev assets
  (`scripts/`, `tests/`, `.github/`, `dist/`, `.git*`) are excluded.
- Override output dir with `--dist`. Override version with `--version`.
- Build also generates `.extension.checksum` file for integrity verification.

## Integrity Checking

The `.checksumignore` file specifies patterns for files excluded from integrity checks:

- **Default exclusions**: `.extension`, `.checksumignore`, and `log/` directory
- **Glob patterns supported**: `*.log`, `keystore/`, `secrets/*.key`, etc.
- **One pattern per line**: Lines starting with `#` are comments
- **Common use cases**: credentials, caches, temporary files, user-specific configs

Example `.checksumignore`:

```text
# Exclude log directory (already default)
log/

# Credentials and secrets
keystore/
*.key
*.pem

# Cache and temporary files
cache/
*.tmp
```

When OraDBA verifies extension integrity, files matching these patterns are skipped.

## Rename Helper

- `scripts/rename-extension.sh --name <newname> [--description "..."] [--workdir <path>]`
- Updates `.extension`, README, the sample config filename in `etc/`, and
  references to the old name (including release notes).
- Run immediately after cloning to avoid manual edits.

## CI and Releases

- CI: shellcheck for scripts, markdownlint for docs, BATS tests for helper scripts.
- Release: on tags `v*.*.*` (or manual dispatch), runs lint/tests, builds
  tarball + checksum, and publishes them as GitHub release assets.

## Using the Template

1. Add your logic to `bin/`, `sql/`, `rcv/`, `etc/`, and `lib/`.
2. Keep `.extension` metadata current (name, version, priority, provides).
3. Users copy any needed settings from `etc/<name>.conf.example` into `${ORADBA_PREFIX}/etc/oradba_customer.conf`.
4. Extract the tarball into `${ORADBA_LOCAL_BASE}`; auto-discovery will load the extension.

## How Extensions Load (OraDBA v0.19.0+)

Extensions are automatically loaded by `oradba_env_builder.sh` after the Oracle environment is fully set up:

### Loading Sequence

1. **Oracle Environment**: ORACLE_HOME, ORACLE_SID, and Oracle paths are set first
2. **Configuration Files**: OraDBA config files are loaded (core → standard → local → customer → SID)
3. **Extension Discovery**: Extensions in `${ORADBA_LOCAL_BASE}` with `.extension` markers are discovered
4. **Priority Sorting**: Extensions are sorted by priority field (lower = loaded first, default: 50)
5. **Extension Loading**: Each enabled extension's directories are added to PATH/SQLPATH based on provides metadata
6. **Final Deduplication**: All paths are deduplicated using `oradba_dedupe_path()`

### PATH Integration

Extensions integrate with PATH based on priority and the "provides" metadata in `.extension`:

```yaml
priority: 50              # Load order (lower = earlier, default: 50)
uses_oradba_libs: false   # Optional: true if extension uses OraDBA common libraries
provides:
  bin: true               # Add bin/ to PATH
  sql: true               # Add sql/ to SQLPATH
  rcv: true               # Add rcv/ to RMAN search paths
```

- **Priority field**: Controls load order (lower number = earlier in PATH)
- **Default priority**: 50 (loads after Oracle paths)
- **Higher priority**: Use 10-40 for tools that should override Oracle commands
- **Lower priority**: Use 60-90 for supplementary tools

Example priorities:
- 10-20: Critical overrides (e.g., custom sqlplus wrapper)
- 30-40: Enhanced tooling (e.g., extended DBA scripts)
- 50: Default (loaded after Oracle, most extensions)
- 60-70: Supplementary utilities (e.g., monitoring scripts)
- 80-90: Low priority additions

### Uses OraDBA Libraries

The optional `uses_oradba_libs` field indicates if the extension uses OraDBA common libraries:

```yaml
uses_oradba_libs: true   # Extension sources oradba_common.sh or other OraDBA libs
```

- **true**: Extension scripts use OraDBA functions (oradba_log, oradba_dedupe_path, etc.)
- **false**: Extension is standalone (default if not specified)
- **Purpose**: Documentation and dependency tracking
- **Example**: Extensions that source `${ORADBA_BASE}/lib/oradba_common.sh`

### Provides Metadata

The `provides` section controls what directories are added:

- `bin: true` - Adds `${EXTENSION_DIR}/bin` to PATH
- `sql: true` - Adds `${EXTENSION_DIR}/sql` to SQLPATH
- `rcv: true` - Adds `${EXTENSION_DIR}/rcv` to ORADBA_RCV_PATHS
- Set to `false` to skip a directory even if it exists

### Environment Variables

Each loaded extension gets:
- `ORADBA_EXT_<NAME>_PATH="${ext_path}"` - Extension path reference
- `<NAME>_BASE="${ext_path}"` - Shorthand base variable (e.g., ODB_DATASAFE_BASE)
- Navigation alias: `cde<name>` - Quick cd to extension directory

### Disabling Extensions

Extensions can be disabled via:
1. **.extension metadata**: Set `enabled: false`
2. **Environment variable**: `export ORADBA_EXT_<NAME>_ENABLED=false`

### Backward Compatibility

**Note**: OraDBA v0.19.0+ changed how extensions load. Pre-v0.19.0 extensions may need:
- Updated `.extension` file with provides section
- No code changes required if using standard bin/sql/rcv structure
