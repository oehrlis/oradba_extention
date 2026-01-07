-- -----------------------------------------------------------------------------
-- OraDBA Extension - Oracle Database Infrastructure and Security
-- -----------------------------------------------------------------------------
-- Name......: extension_simple.sql
-- Author....: Stefan Oehrli (oes) stefan.oehrli@oradba.ch
-- Editor....: Stefan Oehrli
-- Date......: 2026.01.07
-- Revision..: 0.2.0
-- Usage.....: @extension_simple.sql
-- Purpose...: Simple SQL query example for extension template
-- Notes.....: This is a basic example showing minimal SQL script structure
--             with standard header and formatting options.
-- Reference.: https://github.com/oehrlis/oradba_extension
-- License...: Apache License Version 2.0, January 2004 as shown
--             at http://www.apache.org/licenses/
-- -----------------------------------------------------------------------------

-- Display script information
PROMPT ================================================================================
PROMPT Extension Template - Simple Database Information Query
PROMPT ================================================================================

-- Configure SQL*Plus formatting
SET PAGESIZE 200
SET LINESIZE 200
SET VERIFY OFF
SET FEEDBACK ON

-- Query basic database information
SELECT d.name           AS database_name,
       d.dbid           AS database_id,
       d.open_mode      AS open_mode,
       d.log_mode       AS log_mode,
       d.created        AS created_date,
       i.version        AS db_version,
       i.instance_name  AS instance_name,
       i.host_name      AS host_name,
       i.status         AS instance_status
FROM   v$database d,
       v$instance i;

-- Show current session information
PROMPT
PROMPT Current Session Information:
PROMPT

SELECT SYS_CONTEXT('USERENV', 'SESSION_USER')    AS session_user,
       SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')  AS current_schema,
       SYS_CONTEXT('USERENV', 'INSTANCE_NAME')   AS instance_name,
       SYS_CONTEXT('USERENV', 'SERVER_HOST')     AS server_host,
       SYS_CONTEXT('USERENV', 'IP_ADDRESS')      AS client_ip
FROM   dual;

PROMPT
PROMPT Script completed successfully.
PROMPT ================================================================================
