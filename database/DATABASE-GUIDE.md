# SafeNation database guide

## Main database

The complete current website uses `safenation_disaster_link` through
`config/database.php`. The database name is explicit; an inherited DB_NAME
setting cannot select a test database. Host, port and credentials remain configurable.
The application, installer and district maintenance script use this same configuration.

## Table groups

| Purpose | Active tables |
| --- | --- |
| Accounts and access | roles, users, login_attempts |
| Incidents and review | disaster_types, reports, report_reviews |
| Hospitals and shelters | facilities |
| Alerts and messages | alerts, notifications |
| Assistance | assistance_requests |
| Volunteers | volunteers, volunteer_assignments |
| Stock and movements | resources, resource_transactions |
| Administration | audit_logs, settings |

These are 16 active tables. Users connect to reports, assistance, notifications
and assigned facilities through foreign keys. Reports connect to disaster types
and reviews. Resource transactions reference inventory items. Volunteer assignments
reference volunteers and, optionally, an incident. Existing keys and records are unchanged.

## Historical data retained inside the main database

18 tables named `archive_safenation_*` preserve all 57 rows from the older
`safenation` database. Their original primary-key values, column types, password
hashes and relationships are retained. Foreign keys reference archive tables
inside the main database. Constraint names have an archive prefix to avoid collisions.

These are historical archives, not active website accounts, alerts or map records.
The older schema has different roles, statuses and fields. Activating those records
would require a separately reviewed mapping. This preserves the existing website's
behavior while keeping historical data accessible in the same database.
There are 34 tables and 42 foreign-key relationships in the main database in total.

## Why the other databases exist

- safenation: older, structurally different project data; copied into the archive tables.
- safenation_db: empty database, retained unchanged.
- safenation_*qa* and safenation_wording_pages_*: isolated workflow/page checks.
- safenation_*import* and safenation_coverage_sql_*: SQL import verification.
- safenation_coverage_empty_*: installation with no example accounts/reports.
- safenation_coverage_preservation_*: record-preservation regression check.
- mysql, performance_schema, information_schema and phpmyadmin: MySQL/phpMyAdmin
  system databases; keep separate from project tables.
- globetrek_db and test: not referenced by this project; left unchanged.

All source and test databases remain available. No database, table, account,
record, page, feature or project file was deleted. Test-generated reports,
accounts and workflow mutations are not imported into active website tables.

## phpMyAdmin and demonstration

Start Apache and MySQL in XAMPP. Open http://localhost/phpmyadmin/ (adjust the port
if Apache uses another port), then select `safenation_disaster_link` on the left.
Use the Structure tab for tables and Relation view/Designer for foreign keys.
Open this database before demonstrating; other databases remain visible because
we retained them as requested. They are not additional website connections.

A simple explanation: “SafeNation uses one relational MySQL database. Its 16
operational tables organize accounts, incidents, facilities, assistance, volunteers
and resources. Foreign keys keep related records consistent. Clearly prefixed
archive tables preserve data from an earlier version.”

## Backup and SQL files

`database/safenation.sql` is the refreshed snapshot of the current main database,
including archives. It contains account hashes and personal data: keep it local.
Import into an empty installation only; do not execute it over existing tables.
`schema.sql` is the fresh-install operational schema, not a snapshot of current data.
The older project and every database were backed up before configuration or migration.

Backup location: C:\Users\USER\Documents\Codex\2026-10-01\i-have-provided-you-with-two\outputs\database-backup-20261009-165206
- project-complete.zip: every existing project file, including runtime storage.
- application-databases.sql: logical export of all non-system application databases,
  including phpmyadmin. MySQL's internal mysql schema is in the cold backup below.
- mysql-data-complete.zip: complete MySQL data directory copied after shutdown.
- database-inventory.json: original database schemas and row counts.
- legacy-archive-migration.sql and consolidation-result.json: migration and validation.

The archive ZIPs passed integrity checks; copied historical rows were compared
field by field. All active table checksums remained unchanged. Main table health,
foreign keys, website page rendering and countrywide map data were checked.

## Existing server issue

The initial all-database logical export reported an Aria checksum error in
`mysql.db`, a MySQL system privilege table. This was not repaired or modified by
the consolidation. Complete offline files preserve that system data as it stood.
The 34 project tables passed table checks. A separate XAMPP/MySQL maintenance task
is needed for the system-table issue before relying on server-wide logical backups.
