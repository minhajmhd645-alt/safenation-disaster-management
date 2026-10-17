<?php
/** Facility images: real photographs or generated illustrations identified in alt text and metadata. */
function facility_photo_record(array $facility): ?array {
    static $photos = null;
    $root = dirname(__DIR__);
    if ($photos === null) {
        $photos = json_decode(file_get_contents($root . '/config/facility-photos.json'), true) ?: [];
    }
    $photo = $photos[(string)$facility['id']] ?? null;
    // A renamed/reassigned record must be checked again before displaying its old photo.
    if (!$photo || $photo['name'] !== $facility['name'] || $photo['kind'] !== $facility['kind']
        || $photo['district'] !== $facility['area'] || $photo['source_code'] !== $facility['source_code']) return null;
    foreach (['filename', 'small_filename'] as $key) {
        if (!is_file($root . '/assets/images/facilities/' . $photo[$key])) return null;
    }
    return $photo;
}
function facility_photo(array $facility): string {
    $photo = facility_photo_record($facility);
    $generated = ($photo['classification'] ?? '') === 'ai-generated';
    $html = '<figure class="facility-figure"><div class="facility-media">';
    if ($photo) {
        $base = 'assets/images/facilities/';
        $html .= '<img class="facility-photo ' . ($generated ? 'facility-ai-image' : 'facility-real-photo') . '" src="' . e($base . $photo['filename'])
            . '" srcset="' . e($base . $photo['small_filename']) . ' ' . (int)$photo['small_width'] . 'w, '
            . e($base . $photo['filename']) . ' ' . (int)$photo['width'] . 'w"'
            . ' sizes="(max-width: 600px) calc(100vw - 32px), (max-width: 900px) 45vw, 550px"'
            . ' width="' . (int)$photo['width'] . '" height="' . (int)$photo['height']
            . '" alt="' . e($photo['alt']) . '" loading="lazy" decoding="async">';
    } else {
        $html .= '<div class="facility-photo-unavailable">' . icon('facilities')
            . '<span>Verified photograph unavailable</span></div>';
    }
    $html .= '<div class="facility-photo-labels"><span class="facility-kind">' . icon('facilities') . ' '
        . e(strtoupper($facility['kind'])) . '</span>'
        . badge($facility['status'] === 'unknown' ? 'Availability unverified' : $facility['status']) . '</div></div>';
    if ($photo && !$generated) {
        $html .= '<figcaption class="facility-photo-credit"><span class="facility-photo-context">'
            . e($photo['caption']) . '</span><span>Photo: ' . e($photo['author']) . ' · '
            . '<a href="' . e($photo['source_url']) . '" target="_blank" rel="noopener noreferrer">Source</a> · '
            . '<a href="' . e($photo['license_url']) . '" target="_blank" rel="noopener noreferrer">'
            . e($photo['license']) . '</a>. Resized; WebP format.</span></figcaption>';
    }
    return $html . '</figure>';
}
