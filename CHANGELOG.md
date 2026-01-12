# Changelog

## [Unreleased]

### Changed

- **Makefile Consolidation**: Standardized Makefile with oradba conventions
  - Updated header format with author, license, and reference information
  - Renamed variables to match oradba naming: `COLOR_*`, direct tool detection
  - Renamed targets: `lint-sh` → `lint-shell`, `lint-md` → `lint-markdown`
  - Added aliases `lint-sh` and `lint-md` for backward compatibility
  - Standardized error messages and formatting throughout
  - Aligned section headers and structure with oradba/Makefile
  - Maintained extension-specific features: tools, info, status, shortcuts

- **GitHub Actions Workflows**: Updated to use Makefile targets
  - CI workflow uses `make lint-shell`, `make lint-markdown`, `make test`
  - Release workflow uses `make ci` for comprehensive checks
  - Improved consistency and maintainability of workflow definitions

## [0.3.0] - 2026-01-12

### Added

- **Comprehensive Documentation**: Added complete documentation in `doc/` directory
  - `doc/index.md` - Main landing page with overview, features, and quick start
  - `doc/installation.md` - Detailed installation guide with multiple methods and troubleshooting
  - `doc/configuration.md` - Configuration reference with examples, best practices, and security
  - `doc/reference.md` - Complete API and scripts reference with all components
  - `doc/development.md` - Development guide with setup, testing, CI/CD, and contribution process
  - `doc/changelog.md` - Version history following Keep a Changelog format
  - Documentation follows Material for MkDocs conventions
  - Serves as reference example for other extension developers
  - Automatically syncs to main OraDBA documentation site

### Changed

- Documentation structure aligned with OraDBA extension documentation system
- All documentation cross-referenced for easy navigation

## [0.2.0] - 2026-01-07

### Added

- **Checksum Exclusion Support**: Added `.checksumignore` file for customizable
  integrity checks
  - Define patterns for files to exclude from checksum verification
  - Supports glob patterns: `*`, `?`, directory matching (`pattern/`)
  - Default exclusions: `.extension`, `.checksumignore`, `log/`
  - Per-extension configuration in template
  - Common use cases: credentials, caches, temporary files, user-specific configs
  - Included in build tarball for distribution

- **Enhanced SQL Script Examples**: Added comprehensive SQL script templates
  - `sql/extension_simple.sql` - Basic query example with standard formatting
  - `sql/extension_comprehensive.sql` - Production-ready script with:
    - Automatic log directory detection from ORADBA_LOG environment variable
    - Dynamic spool file naming with timestamp and database SID
    - Multiple report sections with proper headers
    - Tablespace usage, session info, top objects, and SQL activity
    - Error handling with WHENEVER OSERROR
    - Integration with OraDBA logging infrastructure
  - Updated `sql/extension_query.sql` with proper header and formatting

- **Enhanced RMAN Script Template**: Comprehensive `rcv/extension_backup.rcv` example
  - Documents all 17+ template tags supported by oradba_rman.sh
  - Full backup workflow: database, archivelogs, controlfile, SPFILE
  - Variable substitution examples: `<BCK_PATH>`, `<START_DATE>`, `<ORACLE_SID>`
  - Safety features: DELETE/CROSSCHECK commands commented out
  - Usage examples with multiple invocation patterns
  - Serves as reference guide for extension developers

### Changed

- **Build Process**: Updated `scripts/build.sh` to include `.checksumignore` in CONTENT_PATHS
- **Documentation**: Enhanced README.md with "Integrity Checking" section
  - Pattern syntax and examples
  - Default exclusions documented
  - Common use case patterns provided

## [0.1.1] - 2026-01-07

### Fixed

- Add .extension.checksum generation to build artifacts
- Fix release workflow heredoc formatting

### Changed

- Add Makefile help target
- Ensure dist directory is auto-created

## [0.1.0] - 2026-01-07

### Added

- Initial template for OraDBA extensions with sample structure, packaging script, rename helper, and CI workflows

### Fixed

- Release workflow fixed (heredoc)
- Build script lint fixes
- Dist auto-creation
- BATS passing

[Unreleased]: https://github.com/oehrlis/oradba_extension/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/oehrlis/oradba_extension/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/oehrlis/oradba_extension/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/oehrlis/oradba_extension/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/oehrlis/oradba_extension/releases/tag/v0.1.0
