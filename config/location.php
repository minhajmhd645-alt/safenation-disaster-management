<?php
// A compatible self-hosted Photon HTTPS endpoint can replace the public service.
return ['provider'=>getenv('SAFENATION_GEOCODER_URL')?:'https://photon.komoot.io'];
