# Location picker

All existing coordinate forms share the Leaflet picker: incident submission and
correction, hospital and shelter creation/editing, and assistance requests.
Coordinates remain in the existing latitude/longitude fields. Optional addresses
for reports and requests are added by `location-picker.sql`; existing values are
preserved. Fresh installations and the full SQL export include these columns.

District detection uses the bundled geoBoundaries gbOpen LKA ADM2 dataset:
https://www.geoboundaries.org/api/current/gbOpen/LKA/ADM2/
Boundary ID LKA-ADM2-46371173, representing 2017; downloaded 8 October 2026.
Source: OpenStreetMap / Wambacher. License: ODbL 1.0.
Coordinates are rounded to six decimal places; Polygon/MultiPolygon islands and
interior holes are retained. These boundaries are a location aid, not a legal
boundary survey. Coastal/reclaimed land near the dataset boundary may require
a point slightly inland and a precise written address. Newly selected coordinates
are validated against these boundaries; unchanged historical positions are preserved.

Place search and approximate address lookup use Photon:
https://github.com/komoot/photon/blob/master/docs/api-v1.md
The public service allows reasonable use but offers no uptime guarantee.
Requests are explicit searches or marker selections, never background polling.
The PHP proxy caches responses for 24 hours and spaces upstream requests by at
least 1.1 seconds. It sends only the search term or selected coordinates.
OpenStreetMap attribution is included on the forms and maps.
Set SAFENATION_GEOCODER_URL to a compatible HTTPS Photon instance to change provider.
Manual coordinates and address entry remain available without geocoding.
