# SafeNation – Disaster Management System

A web-based disaster management system I built as my final project for BSc (Hons) Software Engineering (ICBT Campus / Cardiff Metropolitan University). It helps people report incidents, see alerts, find shelters and hospitals, and helps coordinators and admins manage the response.

Built with plain PHP and MySQL, and runs locally on XAMPP.

## What it does

- Report disaster incidents (with a location picked on a map) and track their review
- Public alerts and a live map of incidents and facilities
- Shelter and hospital directory with district-wise filtering
- Emergency contacts in three languages
- Assistance requests and a volunteer hub
- Resource inventory with a transaction ledger
- Admin pages for accounts and roles, activity audit and system settings
- Automatic severity scoring for reports (Low / Medium / High / Critical)

## Tech used

- PHP (no framework)
- MySQL / MariaDB (database name: `safenation_disaster_link`)
- Leaflet for maps
- HTML, CSS and JavaScript
- XAMPP for local running

## Project structure

```
app/          PHP logic (bootstrap, severity scoring, installer, pages)
app/pages/    Page files (account, community, emergency contacts, facilities, operations)
assets/       CSS, JavaScript, images, Leaflet library
config/       Database and location settings, district and emergency contact data
database/     SQL files and data/source notes
index.php     Entry point
setup.php     First-time database setup page
router.php    Router for PHP's built-in server
```

## How to run it (XAMPP, Windows)

1. Install [XAMPP](https://www.apachefriends.org/).
2. Download this repository (Code → Download ZIP) and extract it into `xampp/htdocs/`. Rename the folder to `safenation-project`.
3. Open XAMPP Control Panel and start **Apache** and **MySQL**.
4. Open `http://localhost/safenation-project/` in your browser.
5. If you see **"Set up SafeNation"**, click **Open local setup** and wait for it to finish. It creates the database automatically.
6. To check the database, open `http://localhost/phpmyadmin` and look for `safenation_disaster_link`.

More details are in `XAMPP-START.md`. The SQL files are in the `database/` folder.

By default the app connects to MySQL as `root` with an empty password (normal for local XAMPP). You can change this with the `DB_HOST`, `DB_PORT`, `DB_USER` and `DB_PASS` environment variables. Please don't use these defaults on a public server.

## Notes

- This is an academic project, not a production system.
- Map data uses OpenStreetMap tiles, so the map needs an internet connection.
- Sources for hospital, location and facility photo data are listed in the `database/` folder.

## Author

Minhaj – Software Engineering student
