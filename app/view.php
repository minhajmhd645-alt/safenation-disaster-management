<?php
declare(strict_types=1);
function icon(string $name): string {
 $paths=['phone'=>'M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6 19.8 19.8 0 0 1-3.1-8.7A2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1 1 .4 2 .7 2.9a2 2 0 0 1-.5 2.1L8 10a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.5c.9.3 1.9.6 2.9.7a2 2 0 0 1 1.7 2z','home'=>'M3 10 12 3l9 7v10H3z M9 20v-7h6v7','map'=>'m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3z M9 3v15 M15 6v15','reports'=>'M6 3h12v18H6z M9 8h6 M9 12h6 M9 16h4','alerts'=>'M12 3 2 21h20z M12 9v5 M12 17h.01','facilities'=>'M4 21V7h16v14 M8 7V3h8v4 M9 13h6 M12 10v6','assistance'=>'M12 21s-9-5-9-12a5 5 0 0 1 9-3 5 5 0 0 1 9 3c0 7-9 12-9 12z','volunteers'=>'M16 21v-3a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v3 M9 10a4 4 0 1 0 0-8 4 4 0 0 0 0 8 M18 8h4 M20 6v4 M19 14a4 4 0 0 1 3 4v3','resources'=>'m3 7 9-4 9 4-9 4z M3 7v10l9 4 9-4V7 M12 11v10','analytics'=>'M3 3v18h18 M7 16v-4 M12 16V7 M17 16v-7','users'=>'M16 21v-3a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v3 M9 10a4 4 0 1 0 0-8 4 4 0 0 0 0 8 M17 3a4 4 0 0 1 0 8 M18 14a4 4 0 0 1 4 4v3','notifications'=>'M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9 M10 21h4','settings'=>'M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8 M12 2v3 M12 19v3 M2 12h3 M19 12h3 M5 5l2 2 M17 17l2 2 M5 19l2-2 M17 7l2-2','audit'=>'M4 3h16v18H4z M8 7h8 M8 11h8 M8 15h5','arrow'=>'M4 12h16 M14 6l6 6-6 6','shield'=>'m12 2 9 4v6c0 6-9 10-9 10S3 18 3 12V6z M8 12l3 3 5-6'];
 return '<svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="'.($paths[$name]??$paths['home']).'"/></svg>';
}
function layout_start(string $title,string $page): void {
 $u=user();$site=(string)(scalar("SELECT value FROM settings WHERE name='site_name'")?:'SafeNation');$unread=$u?(int)scalar('SELECT COUNT(*) FROM notifications WHERE user_id=? AND read_at IS NULL',[$u['id']]):0;
 echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#123b35"><title>'.e($title).' · '.e($site).'</title><link rel="icon" href="assets/logo.svg" type="image/svg+xml"><link rel="stylesheet" href="assets/vendor/leaflet/leaflet.css"><link rel="stylesheet" href="assets/css/app.css?v=facility-images-2"><script defer src="assets/vendor/leaflet/leaflet.js"></script><script defer src="assets/js/app.js?v=location-1"></script><script defer src="assets/js/location-picker.js?v=1"></script></head><body><a class="skip" href="#main">Skip to content</a><div class="shell"><aside class="sidebar" id="sidebar"><a class="brand" href="'.url().'">'.icon('shield').'<span>'.e($site).'<small>DISASTER LINK</small></span></a><div class="nav-label">COMMUNITY</div><nav aria-label="Main navigation">';
 $links=['home'=>['Overview','home'],'map'=>['Situation map','map'],'alerts'=>['Emergency alerts','alerts'],'facilities'=>['Shelters & hospitals','facilities'],'emergency-contacts'=>['Emergency Contacts','phone']];
 if($u)$links+=['dashboard'=>['My dashboard','analytics'],'reports'=>[can('respond')?'Incident reports':'My reports','reports'],'assistance'=>['Assistance requests','assistance'],'volunteers'=>['Volunteer hub','volunteers']];
 foreach($links as $p=>[$label,$ic])echo '<a '.($page===$p?'aria-current="page"':'').' class="nav-item '.($page===$p?'active':'').'" href="'.url($p).'">'.icon($ic).e($label).'</a>';
 if(can('coordinate')){echo '<div class="nav-label">OPERATIONS</div>';foreach(['resources'=>['Resource inventory','resources'],'analytics'=>['Insights & analytics','analytics']] as $p=>[$label,$ic])echo '<a class="nav-item '.($page===$p?'active':'').'" href="'.url($p).'">'.icon($ic).e($label).'</a>';}
 if(can('admin')){echo '<div class="nav-label">ADMINISTRATION</div>';foreach(['users'=>['Accounts & roles','users'],'audit'=>['Activity audit','audit'],'settings'=>['System settings','settings']] as $p=>[$label,$ic])echo '<a class="nav-item '.($page===$p?'active':'').'" href="'.url($p).'">'.icon($ic).e($label).'</a>';}
 echo '</nav><div class="sidebar-bottom"><span class="status-dot"></span> Disaster coordination<small>Reports reviewed by our coordination team.</small></div></aside><div class="workspace"><header class="topbar"><button class="icon-button menu-toggle" aria-label="Toggle navigation" aria-expanded="false">☰</button><div class="breadcrumb">SafeNation <span>/</span> '.e($title).'</div><div class="top-actions">';
 if($u){echo '<a class="notification-link" aria-label="Notifications, '.$unread.' unread" href="'.url('notifications').'">'.icon('notifications').($unread?'<b>'.$unread.'</b>':'').'</a><a class="user-link" href="'.url('profile').'"><span class="avatar">'.e(mb_substr($u['name'],0,1)).'</span><span>'.e($u['name']).'<small>'.e(ucwords(str_replace('_',' ',$u['role']))).'</small></span></a><form method="post" class="inline">';token();echo '<input type="hidden" name="action" value="logout"><button class="text-button">Sign out</button></form>';}
 else echo '<a class="text-button" href="'.url('login').'">Sign in</a><a class="button small" href="'.url('register').'">Join SafeNation</a>';
 echo '</div></header><main id="main">';
 $announcement=(string)scalar("SELECT value FROM settings WHERE name='announcement'");
 if(trim($announcement)!=='')echo '<div class="environment-note">'.e($announcement).'</div>';
 foreach($_SESSION['flash']??[] as $f)echo '<div class="flash '.e($f['kind']).'" role="status">'.e($f['message']).'</div>';unset($_SESSION['flash']);
}
function layout_end(): void {echo '</main><footer>SafeNation – Disaster Link </footer></div></div></body></html>';}
function heading(string $eyebrow,string $title,string $subtitle,string $action=''): void {echo '<div class="page-heading"><div><p class="eyebrow">'.e($eyebrow).'</p><h1>'.e($title).'</h1><p class="muted">'.e($subtitle).'</p></div>'.$action.'</div>';}
function start_form(string $action,string $title='',string $class=''): void {$GLOBALS['current_form_action']=$action;echo '<form method="post" class="card form-card '.e($class).'">';token();echo '<input type="hidden" name="action" value="'.e($action).'">';if($title)echo '<h2>'.e($title).'</h2>';}
function end_form(string $label='Save changes'): void {echo '<div class="form-actions"><button class="button">'.e($label).'</button></div></form>';}
function field(string $name,string $label,string $type='text',mixed $value='',bool $required=true,string $attrs=''): void {if($type!=='password'&&($_POST['action']??null)===($GLOBALS['current_form_action']??'')&&isset($_POST[$name])&&is_scalar($_POST[$name]))$value=$_POST[$name];echo '<label class="field"><span>'.e($label).'</span><input name="'.e($name).'" type="'.e($type).'" value="'.e($value).'" '.($required?'required':'').' '.$attrs.'></label>';}
function textarea(string $name,string $label,string $value='',int $min=0,int $max=5000): void {if(($_POST['action']??null)===($GLOBALS['current_form_action']??'')&&isset($_POST[$name])&&is_scalar($_POST[$name]))$value=(string)$_POST[$name];echo '<label class="field"><span>'.e($label).'</span><textarea name="'.e($name).'" rows="4" '.($min?'required':'').' minlength="'.$min.'" maxlength="'.$max.'">'.e($value).'</textarea></label>';}
function select(string $name,string $label,array $options,mixed $selected=''): void {if(($_POST['action']??null)===($GLOBALS['current_form_action']??'')&&isset($_POST[$name])&&is_scalar($_POST[$name]))$selected=$_POST[$name];echo '<label class="field"><span>'.e($label).'</span><select name="'.e($name).'">';foreach($options as $v=>$l)echo '<option value="'.e($v).'" '.((string)$v===(string)$selected?'selected':'').'>'.e($l).'</option>';echo '</select></label>';}
function type_select(mixed $v=''): void {select('type_id','Disaster category',array_column(types(),'name','id'),$v);}
function severity_select(string $v='Medium'): void {select('severity','Reviewed severity',array_combine(['Low','Medium','High','Critical'],['Low','Medium','High','Critical']),$v);}
function location_fields(array $r=[],bool $districtOnly=false): void {
 static $count=0;$id='location-picker-'.(++$count);
 echo '<fieldset class="location-fields"><legend>Select location</legend><p class="hint">Search for a place, click the map, or drag the marker. Check the suggested district and address before saving.</p><div class="location-search"><label class="field"><span>Search for a place in Sri Lanka</span><input class="place-query" type="search" maxlength="150" placeholder="Town, hospital, road or landmark" autocomplete="off"></label><button type="button" class="button secondary place-search">Find location</button></div><div class="place-results" role="region" aria-label="Location search results"></div><div id="'.e($id).'" class="location-picker-map" aria-label="Select a location on the Sri Lanka map"></div><div class="form-grid">';
 $options=[''=>'Select district']+array_combine(districts(),districts());if(!empty($r['area'])&&!isset($options[$r['area']]))$options[$r['area']]=$r['area'];select('area','District',$options,$r['area']??'');
 field('latitude','Latitude','number',$r['latitude']??'',true,'min="5.5" max="10.2" step="any"');field('longitude','Longitude','number',$r['longitude']??'',true,'min="79" max="82.5" step="any"');echo '</div>';
 if(!$districtOnly)field('address','Address or nearby landmark (optional)','text',$r['address']??'',false,'maxlength="255"');
 echo '<div class="form-actions"><button type="button" class="button secondary small geolocate">Use my location</button><button type="button" class="button secondary small lookup-address">Look up address</button></div><p class="geo-status hint" role="status" aria-live="polite">Choose a map point or enter coordinates.</p><p class="hint">Map and place data © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap contributors</a>. District boundaries: <a href="https://www.geoboundaries.org/">geoBoundaries</a>. Place search uses Photon and needs internet access. Search terms and coordinates used for address lookup are sent to the lookup service. Suggested addresses may be approximate; you can edit them.</p></fieldset>';
}
function empty_state(string $title,string $message): void {echo '<div class="empty">'.icon('shield').'<h3>'.e($title).'</h3><p>'.e($message).'</p></div>';}
function metrics(array $items): void {echo '<div class="metrics">';foreach($items as [$label,$value,$detail,$ic])echo '<div class="metric card"><div class="metric-top">'.e($label).icon($ic).'</div><strong>'.e($value).'</strong><small>'.e($detail).'</small></div>';echo '</div>';}
function report_list(array $rows): void {if(!$rows){empty_state('No incidents to show','Reports appear here when they match your filters.');return;}echo '<div class="table-wrap"><table><thead><tr><th>Incident</th><th>Area</th><th>Severity</th><th>Status</th><th>Reported</th></tr></thead><tbody>';foreach($rows as $r)echo '<tr><td><div class="incident-cell">'.visual_image($r['type'],'incident-thumbnail',false,'60px').'<div><a class="table-title" href="'.url('report',['id'=>$r['id']]).'">'.e($r['title']).'</a><small>#'.e($r['id']).' · '.e($r['type']).'</small></div></div></td><td>'.e($r['area']).'</td><td>'.badge($r['severity']).'</td><td>'.badge($r['status']).'</td><td>'.e(date('d M Y · H:i',strtotime($r['created_at']))).'</td></tr>';echo '</tbody></table></div>';}
function pager(int $total,int $per,string $page,array $params=[]): void {$n=max(1,(int)($_GET['p']??1));$count=(int)ceil($total/$per);if($count<=1)return;echo '<nav class="pagination" aria-label="Pagination">';if($n>1)echo '<a class="button secondary small" href="'.e(url($page,$params+['p'=>$n-1])).'">Previous</a>';echo '<span>Page '.$n.' of '.$count.'</span>';if($n<$count)echo '<a class="button secondary small" href="'.e(url($page,$params+['p'=>$n+1])).'">Next</a>';echo '</nav>';}


/** Generated editorial illustrations. Never incident evidence or actual facility photos. */
function image_asset(string $subject): array {
    $assets = [
        'community' => ['community', 'Illustration of community volunteers preparing drinking water and relief boxes'],
        'flood' => ['flood', 'Illustration of monsoon floodwater surrounding homes on a tropical street'],
        'fire' => ['fire', 'Illustration of flames and smoke at a small tiled-roof building'],
        'landslide' => ['landslide', 'Illustration of a landslide covering part of a hill-country road'],
        'storm' => ['storm', 'Illustration of strong coastal winds bending palm trees beside rough seas'],
        'heavy rainfall' => ['rainfall', 'Illustration of heavy monsoon rain and roof runoff along a residential lane'],
        'shelter' => ['shelter', 'Illustration of a prepared community shelter with cots, blankets and water supplies'],
        'hospital' => ['hospital', 'Illustration of a hospital entrance with an accessible ramp and tropical planting'],
    ];
    $key = strtolower(trim($subject));
    if (in_array($key, ['cyclone', 'typhoon', 'hurricane'], true)) $key = 'storm';
    return $assets[$key] ?? $assets['community'];
}
function visual_image(string $subject, string $class = '', bool $eager = false, string $sizes = '100vw'): string {
    [$name, $alt] = image_asset($subject);
    $base = 'assets/images/' . $name;
    $sources = $base . '-240.webp 240w, ' . $base . '-480.webp 480w, ' . $base . '.webp 960w';
    return '<img class="' . e($class) . '" src="' . e($base) . '.webp" srcset="' . e($sources) . '" sizes="' . e($sizes) . '" width="960" height="640" alt="' . e($alt) . '" loading="' . ($eager ? 'eager' : 'lazy') . '" decoding="async"' . ($eager ? ' fetchpriority="high"' : '') . '>';
}
function incident_visual(string $type, string $class = 'incident-visual'): string {
    return '<figure class="' . e($class) . '">' . visual_image($type, 'category-photo', false, '(max-width: 600px) calc(100vw - 72px), (max-width: 900px) 80vw, 650px') . '</figure>';
}
