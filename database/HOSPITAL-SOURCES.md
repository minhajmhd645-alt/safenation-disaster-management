# Sri Lankan hospital directory

The directory contains one government hospital in each of Sri Lanka's 25 districts.
Names and district assignments were cross-checked against the Ministry of Health's
[List of Hospitals 2026](https://www.health.gov.lk/wp-content/uploads/2025/06/List-of-Hospitals-2026-compressed.pdf).
Kalmunai is a separate RDHS region within Ampara District, not a 26th district.

Coordinates were extracted from the [Global Healthsites Mapping Project's Sri Lanka dataset](https://data.humdata.org/dataset/sri-lanka-healthsites), retrieved on 8 October 2026.
Point coordinates are retained; polygon locations use the mapped hospital site's
centroid. Each JSON record includes the original mapped name and OpenStreetMap
feature link, allowing the pin to be checked. Some older mapped names differ from
the hospital's current classification in the Ministry list.

Location data © OpenStreetMap contributors, available under the
[Open Database License](https://www.openstreetmap.org/copyright).
Addresses use mapped street names where present, town and district. They are
location descriptions, not verified postal addresses or hospital entrance routing.

Directory entries have unconfirmed operational status, capacity and occupancy,
and no invented phone numbers or claims about live emergency services. Their
zero storage values are displayed as unknown, rather than zero available beds.
Authorized coordinators and assigned facility managers can confirm and update
them through the existing facility form.

Fresh installations seed this directory whether demonstration records are enabled
or disabled. Existing installations can run `update-district-coverage.php` with
XAMPP PHP, or import `district-coverage.sql` in phpMyAdmin after selecting their
database. Both imports retain existing facilities and skip already imported entries.
