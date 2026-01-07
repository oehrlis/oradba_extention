# Changelog

## 0.2.0 - 2026-01-07

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

## 0.1.1 - 2026-01-07

- Add .extension.checksum generation to build artifacts
- Fix release workflow heredoc formatting
- Add Makefile help target and ensure dist auto-created

## 0.1.0 - 2026-01-07

- Initial template for OraDBA extensions with sample structure, packaging script, rename helper, and CI workflows.
- Release workflow fixed (heredoc), build script lint fixes, dist auto-creation, BATS passing, Makefile help target added.
