-- -----------------------------------------------------------------------------
-- OraDBA Extension - Oracle Database Infrastructure and Security
-- -----------------------------------------------------------------------------
-- Name......: extension_query.sql
-- Author....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
-- Editor....: Stefan Oehrli
-- Date......: 2026.01.07
-- Revision..: 0.2.0
-- Usage.....: @extension_query.sql
-- Purpose...: Basic SQL query example for extension template
-- Notes.....: Minimal example - replace with your own query
-- Reference.: https://github.com/oehrlis/oradba_extension
-- License...: Apache License Version 2.0, January 2004 as shown
--             at http://www.apache.org/licenses/
-- -----------------------------------------------------------------------------

PROMPT Extension template SQL sample
PROMPT Replace this with your own query

SET PAGESIZE 200
SET LINESIZE 200

SELECT name,
       open_mode,
       created,
       log_mode
FROM   v$database;
