<?php
declare(strict_types=1);
date_default_timezone_set('Asia/Colombo');
ini_set('display_errors','0');
ini_set('session.use_strict_mode','1');
$sessionPath=dirname(__DIR__).'/storage/sessions';
if(!is_dir($sessionPath))mkdir($sessionPath,0700,true);
session_save_path($sessionPath);
session_name('safenation_session');
session_set_cookie_params(['httponly'=>true,'samesite'=>'Lax','secure'=>!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS']!=='off']);
session_start();
header('Cache-Control: no-store, private');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: strict-origin-when-cross-origin');
header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https://*.tile.openstreetmap.org; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'");
require __DIR__.'/Severity.php';
require __DIR__.'/Location.php';
function config(): array {static $c; return $c ??= require dirname(__DIR__).'/config/database.php';}
function db(): PDO {static $p; if (!$p) {$c=config();$p=new PDO("mysql:host={$c['host']};port={$c['port']};dbname={$c['database']};charset=utf8mb4",$c['username'],$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,PDO::ATTR_EMULATE_PREPARES=>false]);$p->exec("SET time_zone = '+05:30'");}return $p;}
function query(string $sql,array $args=[]): PDOStatement {$s=db()->prepare($sql);$s->execute($args);return $s;}
function all(string $sql,array $args=[]): array {return query($sql,$args)->fetchAll();}
function one(string $sql,array $args=[]): ?array {return query($sql,$args)->fetch() ?: null;}
function scalar(string $sql,array $args=[]): mixed {return query($sql,$args)->fetchColumn();}
function e(mixed $v): string {return htmlspecialchars((string)$v,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');}
function url(string $page='home',array $args=[]): string {return 'index.php?'.http_build_query(['page'=>$page]+$args);}
function go(string $page,array $args=[]): never {header('Location: '.url($page,$args));exit;}
function user(): ?array {static $loaded=false,$u=null;if (!$loaded) {$loaded=true;if(isset($_SESSION['uid'])) $u=one('SELECT * FROM users WHERE id=? AND active=1',[$_SESSION['uid']]);}return $u;}
function can(string $ability): bool {$role=user()['role']??'';$permissions=['coordinate'=>['admin','authority'],'respond'=>['admin','authority','responder'],'facilities'=>['admin','authority','facility_manager'],'admin'=>['admin']];return in_array($role,$permissions[$ability]??[],true);}
function need_login(): void {if(!user()) {flash('Please sign in to continue.','info');go('login');}if(time()-($_SESSION['last_seen']??time())>3600){session_unset();flash('Your session expired. Please sign in.','info');go('login');}$_SESSION['last_seen']=time();}
function need(string $ability): void {need_login();if(!can($ability)) {http_response_code(403);throw new RuntimeException('You do not have permission to access this function.');}}
function csrf(): string {return $_SESSION['csrf']??=bin2hex(random_bytes(32));}
function token(): void {echo '<input type="hidden" name="csrf" value="'.e(csrf()).'">';}
function check_csrf(): void {if(!hash_equals(csrf(),(string)($_POST['csrf']??''))) {http_response_code(403);throw new RuntimeException('Your form expired. Reload the page and try again.');}}
function flash(string $message,string $kind='success'): void {$_SESSION['flash'][]=['message'=>$message,'kind'=>$kind];}
function txt(string $key,int $min=1,int $max=5000): string {$v=trim((string)($_POST[$key]??''));if(mb_strlen($v)<$min || mb_strlen($v)>$max) throw new InvalidArgumentException(ucwords(str_replace('_',' ',$key))." must contain $min–$max characters.");return $v;}
function choice(string $key,array $allowed): string {$v=txt($key);if(!in_array($v,$allowed,true))throw new InvalidArgumentException('Select a valid '.str_replace('_',' ',$key).'.');return $v;}
function number(string $key,float $min,float $max): float {$raw=$_POST[$key]??null;if(!is_numeric($raw)||!is_finite((float)$raw)||(float)$raw<$min||(float)$raw>$max)throw new InvalidArgumentException(ucwords(str_replace('_',' ',$key))." must be between $min and $max.");return (float)$raw;}
function integer(string $key,int $min,int $max): int {$n=number($key,$min,$max);if(floor($n)!==$n)throw new InvalidArgumentException('Enter a whole number for '.$key.'.');return (int)$n;}
function coords(): array {return [number('latitude',5.5,10.2),number('longitude',79,82.5)];}
function location_area(float $lat,float $lng,?array $previous=null): string {
 $area=txt('area',2,100);
 // Preserve unchanged historical localities, while validating newly selected positions.
 if($previous && $area===$previous['area'] && abs($lat-(float)$previous['latitude'])<0.00000005 && abs($lng-(float)$previous['longitude'])<0.00000005)return $area;
 $district=Location::district($lat,$lng);
 if(!$district)throw new InvalidArgumentException('Choose a location on land within Sri Lanka.');
 if(!in_array($area,districts(),true))throw new InvalidArgumentException('Select a valid Sri Lankan district.');
 if($area!==$district)throw new InvalidArgumentException('The selected coordinates are in '.$district.'. Select the matching district or move the marker.');
 return $area;
}

function dt(string $key,bool $optional=false): ?string {$v=trim((string)($_POST[$key]??''));if($v===''&&$optional)return null;$d=DateTime::createFromFormat('Y-m-d\TH:i',$v);if(!$d || $d->format('Y-m-d\TH:i')!==$v)throw new InvalidArgumentException('Enter a valid date and time.');return $d->format('Y-m-d H:i:s');}
function audit(string $action,string $entity,?int $id=null,string $detail=''): void {query('INSERT INTO audit_logs(user_id,action,entity,entity_id,detail) VALUES(?,?,?,?,?)',[user()['id']??null,$action,$entity,$id,$detail]);}
function notify(int $uid,string $title,string $message,string $link): void {query('INSERT INTO notifications(user_id,title,message,link) VALUES(?,?,?,?)',[$uid,$title,$message,$link]);}
function notify_coordinators(string $title,string $message,string $link): void {foreach(all("SELECT id FROM users WHERE active=1 AND role IN ('admin','authority')") as $u)notify((int)$u['id'],$title,$message,$link);}
function badge(string $value): string {return '<span class="badge '.e(strtolower(str_replace(' ','-',$value))).'">'.e(ucfirst(str_replace('_',' ',$value))).'</span>';}
function districts(): array {static $names;return $names ??= require dirname(__DIR__).'/config/districts.php';}
function types(): array {return all('SELECT * FROM disaster_types ORDER BY name');}
function type_id(): int {$id=integer('type_id',1,10000);if(!one('SELECT id FROM disaster_types WHERE id=?',[$id]))throw new InvalidArgumentException('Select a valid disaster category.');return $id;}
function distance(float $a,float $b,float $c,float $d): float {$x=sin(deg2rad($c-$a)/2)**2+cos(deg2rad($a))*cos(deg2rad($c))*sin(deg2rad($d-$b)/2)**2;return 6371*2*atan2(sqrt($x),sqrt(max(0,1-$x)));}
function duplicates(array $r): array {$rows=all("SELECT r.*,t.name type FROM reports r JOIN disaster_types t ON t.id=r.type_id WHERE r.id<>? AND r.type_id=? AND r.status NOT IN ('rejected','duplicate','merged') AND ABS(TIMESTAMPDIFF(HOUR,r.occurred_at,?))<=48 ORDER BY r.id DESC LIMIT 100",[$r['id'],$r['type_id'],$r['occurred_at']]);$out=[];foreach($rows as $v){$km=distance((float)$r['latitude'],(float)$r['longitude'],(float)$v['latitude'],(float)$v['longitude']);similar_text(strtolower($r['description']),strtolower($v['description']),$similarity);if($km<=5&&$similarity>=20){$v['distance']=$km;$v['similarity']=$similarity;$out[]=$v;}}return $out;}

function portal_options(): array {
 return [
  'admin'=>['Administrator Portal','Manage accounts, system settings and activity records.','shield'],
  'authority'=>['Authority Coordinator Portal','Review incident reports and coordinate relief efforts.','reports'],
  'citizen'=>['Citizen Portal','Report incidents, request assistance and follow updates.','users'],
  'responder'=>['Response Team Portal','Follow verified incidents and manage assigned response work.','assistance'],
  'facility_manager'=>['Facility Manager Portal','Update your assigned hospitals, shelters and availability.','facilities'],
 ];
}
function selected_portal(): string {
 $value=$_GET['portal']??$_POST['portal']??'';
 if(!is_string($value)||($value!==''&&!isset(portal_options()[$value])) || (isset($_GET['portal'],$_POST['portal'])&&$_GET['portal']!==$_POST['portal'])) {
  http_response_code(400);throw new RuntimeException('This portal link is invalid. Choose a portal from the overview.');
 }
 return $value;
}
