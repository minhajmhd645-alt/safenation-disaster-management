<?php
require __DIR__.'/app/bootstrap.php';
require __DIR__.'/app/actions.php';
require __DIR__.'/app/view.php';
require __DIR__.'/app/pages/community.php';
require __DIR__.'/app/pages/facilities.php';
require __DIR__.'/app/pages/operations.php';
require __DIR__.'/app/pages/account.php';
require __DIR__.'/app/pages/emergency_contacts.php';
$page=(string)($_GET['page']??'home');
$pages=['home'=>'Community overview','login'=>'Sign in','register'=>'Create account','dashboard'=>'My dashboard','reports'=>'Incident reports','new-report'=>'Report an incident','report'=>'Incident details','alerts'=>'Emergency alerts','map'=>'Situation map','facilities'=>'Shelters & hospitals','emergency-contacts'=>'Emergency Contacts','assistance'=>'Assistance requests','volunteers'=>'Volunteer hub','resources'=>'Resource inventory','analytics'=>'Insights & analytics','profile'=>'My profile','notifications'=>'Notifications','users'=>'Accounts & roles','audit'=>'Activity audit','settings'=>'System settings'];
try {db();scalar('SELECT COUNT(*) FROM users');}catch(Throwable $ex){http_response_code(503);echo '<!doctype html><html lang="en"><meta charset="utf-8"><title>SafeNation setup</title><link rel="stylesheet" href="assets/css/app.css"><main><div class="card padded"><h1>Set up SafeNation</h1><p>The database is not ready or cannot be reached. Start MySQL in XAMPP and check config/database.php.</p><a class="button" href="setup.php">Open local setup</a></div></main></html>';exit;}
if($page==='location-data')Location::api();
if($page==='map-data') {header('Content-Type: application/json; charset=utf-8');echo json_encode(['incidents'=>all("SELECT r.id,r.title,r.area,r.address,r.latitude,r.longitude,r.severity,r.status,r.response_status,t.name type FROM reports r JOIN disaster_types t ON t.id=r.type_id WHERE r.status IN ('verified','resolved') ORDER BY r.id DESC"),'facilities'=>all('SELECT id,name,kind,area,latitude,longitude,status,capacity,occupancy,capacity_known,address,phone,source_url FROM facilities')],JSON_UNESCAPED_UNICODE|JSON_HEX_TAG);exit;}
if($page==='export'){need('coordinate');$days=(int)($_GET['days']??30);if(!in_array($days,[7,30,90,365],true))$days=30;header('Content-Type: text/csv; charset=utf-8');header('Content-Disposition: attachment; filename="safenation-verified-incidents.csv"');$out=fopen('php://output','w');fputcsv($out,['ID','Title','Category','Area','Severity','Status','Created']);foreach(all("SELECT r.id,r.title,t.name,r.area,r.severity,r.status,r.created_at FROM reports r JOIN disaster_types t ON t.id=r.type_id WHERE r.status IN ('verified','resolved') AND r.created_at>=DATE_SUB(NOW(),INTERVAL $days DAY) ORDER BY r.id DESC") as $row){foreach($row as &$v)if(is_string($v)&&preg_match('/^[=+@\-\t\r]/',$v))$v="'".$v;unset($v);fputcsv($out,array_values($row));}fclose($out);exit;}
if($_SERVER['REQUEST_METHOD']==='POST'){try{handle_action();}catch(PDOException $ex){error_log((string)$ex);flash('The database could not save your changes. Please try again.','error');}catch(InvalidArgumentException|RuntimeException $ex){flash($ex->getMessage(),'error');}catch(Throwable $ex){error_log((string)$ex);flash('We could not save your changes. Please try again.','error');}}
if(!isset($pages[$page])){http_response_code(404);$page='not-found';}
// Buffer page rendering so failed authorization never leaves a partial layout.
ob_start();$error=null;
try {if($page==='not-found')throw new RuntimeException('Page not found.');$fn='page_'.str_replace('-','_',$page);if(in_array($page,['login','register'],true))page_auth($page);else $fn();$body=ob_get_clean();}
catch(Throwable $ex){ob_end_clean();if($ex instanceof PDOException || !($ex instanceof RuntimeException)){error_log((string)$ex);$error='Unable to load this page. Please try again.';http_response_code(500);}else{$error=$ex->getMessage();if(http_response_code()===200)http_response_code(404);}$body='';}
layout_start($pages[$page]??'Page unavailable',$page);if($error)echo '<section class="card padded"><h1>Page unavailable</h1><p>'.e($error).'</p><a class="button secondary" href="'.url().'">Return to overview</a></section>';else echo $body;layout_end();
