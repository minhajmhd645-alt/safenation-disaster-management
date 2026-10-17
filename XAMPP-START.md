# Run SafeNation through XAMPP

Start Apache and MySQL in the XAMPP Control Panel, then open:

http://localhost/safenation-project/

If Apache was already running when this mapping was added, stop and start Apache
once to load it. No VS Code terminal or PHP development server is needed.

Apache's `conf/extra/httpd-safenation.conf` maps this URL to the existing Desktop
project. The older `D:/xampp/htdocs/SafeNation` folder is untouched. Keep the Desktop
folder in place, or update the Apache mapping if you move it.

The website still uses `safenation_disaster_link`. Existing routing, private-file
protection, database configuration, design and features are unchanged.

The mapping passed Apache syntax checks. Testing through XAMPP Apache on an
isolated port covered 17 pages, administrator sign-in/out, maps, location selection,
registration required-field validation, assets and private-file protection.
The normal port-80 URL requires the running Apache instance to reload its configuration.
