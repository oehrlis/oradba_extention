# Changelog

## 0.2.0 - 2026-01-07

### Added

- **Checksum Exclusion Support**: Added `.checksumignore` file for customizable integrity checks
  - Define patterns for files to exclude from checksum verification
  - Supports glob patterns: `*`, `?`, directory matching (`pattern/`)
  - Default exclusions: `.extension`, `.checksumignore`, `log/`
  - Per-extension configuration in template
  - Common use cases: credentials, caches, temporary files, user-specific configs
  - Included in build tarball for distribution

### Changed

- **Build Process**: Updated `scripts/build.sh` to include `.checksumignore` in CONTENT_PATHS
- **Documentation**: Enhanced README.md with "Integrity Checking" section
  - Pattern syntax and examples
  - Default exclusions documented
  - Common use case patterns provided

## 0.1.1 - 2026-01-07

- Add .extension.checksum generation to build artifacts
- Fix release workflow heredoc formatting
- Add Makefile help target and ensure dist auto-created

## 0.1.0 - 2026-01-07

- Initial template for OraDBA extensions with sample structure, packaging script, rename helper, and CI workflows.
- Release workflow fixed (heredoc), build script lint fixes, dist auto-creation, BATS passing, Makefile help target added.
