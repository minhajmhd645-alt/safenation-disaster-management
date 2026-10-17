<?php
declare(strict_types=1);
final class Location {
 public static function boundaries(): array {
  static $data;return $data??=json_decode(file_get_contents(dirname(__DIR__).'/database/district-boundaries.json'),true,512,JSON_THROW_ON_ERROR);
 }
 private static function ring(float $x,float $y,array $ring): bool {
  $inside=false;$j=count($ring)-1;
  foreach($ring as $i=>$p){$q=$ring[$j];if(($p[1]>$y)!==($q[1]>$y)&&$x<($q[0]-$p[0])*($y-$p[1])/($q[1]-$p[1])+$p[0])$inside=!$inside;$j=$i;}return $inside;
 }
 public static function district(float $lat,float $lng): ?string {
  foreach(self::boundaries()['features'] as $f){
   $b=$f['bbox'];if($lng<$b[0]||$lat<$b[1]||$lng>$b[2]||$lat>$b[3])continue;
   $polygons=$f['geometry']['type']==='Polygon'?[$f['geometry']['coordinates']]:$f['geometry']['coordinates'];
   foreach($polygons as $p){if(!self::ring($lng,$lat,$p[0]))continue;$hole=false;foreach(array_slice($p,1) as $ring)if(self::ring($lng,$lat,$ring))$hole=true;if(!$hole)return $f['properties']['name'];}
  }return null;
 }
 public static function geocode(string $mode,array $params): array {
  $c=require dirname(__DIR__).'/config/location.php';$dir=dirname(__DIR__).'/storage/geocoding';if(!is_dir($dir))mkdir($dir,0700,true);
  $key=hash('sha256',$c['provider'].'|'.$mode.'|'.json_encode($params));$file="$dir/$key.json";
  if(is_file($file)&&filemtime($file)>time()-86400)return json_decode(file_get_contents($file),true,512,JSON_THROW_ON_ERROR);
  // One upstream request at a time across all sessions; repeated lookups are cached.
  $lock=fopen("$dir/provider.lock",'c+');if(!$lock||!flock($lock,LOCK_EX|LOCK_NB))throw new RuntimeException('Location search is busy. Please try again shortly.');
  try{
   $last=(float)stream_get_contents($lock);$wait=1.1-(microtime(true)-$last);if($wait>0)usleep((int)($wait*1000000));
   $url=rtrim($c['provider'],'/').($mode==='search'?'/api/':'/reverse/').'?'.http_build_query($params+['lang'=>'en','limit'=>6]);
   $ch=curl_init($url);curl_setopt_array($ch,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_CONNECTTIMEOUT=>4,CURLOPT_TIMEOUT=>8,CURLOPT_USERAGENT=>'SafeNation-University-Project/1.0',CURLOPT_PROTOCOLS=>CURLPROTO_HTTPS]);
   $raw=curl_exec($ch);$status=curl_getinfo($ch,CURLINFO_RESPONSE_CODE);curl_close($ch);rewind($lock);ftruncate($lock,0);fwrite($lock,(string)microtime(true));
   if($raw===false||$status!==200)throw new RuntimeException('Online address lookup is unavailable. You can still choose a map point and enter its address.');
   $data=json_decode($raw,true,512,JSON_THROW_ON_ERROR);if(!isset($data['features']))throw new RuntimeException('No location details were returned.');
   file_put_contents($file,json_encode($data),LOCK_EX);return $data;
  }finally{flock($lock,LOCK_UN);fclose($lock);}
 }
 public static function result(array $f): ?array {
  $p=$f['properties']??[];$xy=$f['geometry']['coordinates']??[];if(count($xy)!==2||strtoupper($p['countrycode']??'')!=='LK')return null;
  $district=self::district((float)$xy[1],(float)$xy[0]);if(!$district)return null;
  $parts=[];foreach(['name','housenumber','street','locality','city','postcode'] as $k)if(!empty($p[$k]))$parts[]=$p[$k];$parts[]=$district;$parts[]='Sri Lanka';
  return ['label'=>mb_substr(implode(', ',array_unique($parts)),0,255),'latitude'=>(float)$xy[1],'longitude'=>(float)$xy[0],'district'=>$district];
 }
 public static function api(): never {
  header('Content-Type: application/json; charset=utf-8');
  try{
   if(!user()){http_response_code(401);throw new RuntimeException('Sign in to select a location.');}
   if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);throw new RuntimeException('Use a location form to search.');}check_csrf();
   $mode=(string)($_POST['mode']??'');
   if($mode==='districts'){session_write_close();echo json_encode(self::boundaries());exit;}
   if(!in_array($mode,['search','reverse'],true))throw new InvalidArgumentException('Unknown location request.');
   $last=$_SESSION['location_request']??0;if(microtime(true)-$last<0.7){http_response_code(429);throw new RuntimeException('Please wait a moment before searching again.');}$_SESSION['location_request']=microtime(true);session_write_close();
   if($mode==='reverse'){
    $lat=filter_var($_POST['latitude']??null,FILTER_VALIDATE_FLOAT);$lng=filter_var($_POST['longitude']??null,FILTER_VALIDATE_FLOAT);if($lat===false||$lng===false||$lat<5.5||$lat>10.2||$lng<79||$lng>82.5)throw new InvalidArgumentException('Select a location in Sri Lanka.');
    $district=self::district($lat,$lng);if(!$district)throw new InvalidArgumentException('This point is outside the mapped Sri Lankan districts. Choose an inland point or check your coordinates.');
    $out=['district'=>$district,'address'=>'','message'=>''];
    try{$data=self::geocode($mode,['lat'=>$lat,'lon'=>$lng,'radius'=>1]);foreach($data['features'] as $f){$r=self::result($f);if($r&&$r['district']===$district){$out['address']=$r['label'];break;}}}catch(Throwable $e){$out['message']='Address lookup is unavailable. Enter the address manually.';}
    echo json_encode($out,JSON_UNESCAPED_UNICODE);exit;
   }
   $q=trim((string)($_POST['q']??''));if(mb_strlen($q)<2||mb_strlen($q)>150)throw new InvalidArgumentException('Enter a place name between 2 and 150 characters.');
   $rows=[];$message='';try{$data=self::geocode('search',['q'=>$q,'bbox'=>'79,5.5,82.5,10.2']);foreach($data['features'] as $f)if($r=self::result($f))$rows[]=$r;}catch(Throwable $e){$message='Online search is unavailable. Showing matching saved hospitals where possible.';}
   if(!$rows)foreach(json_decode(file_get_contents(dirname(__DIR__).'/database/hospitals.json'),true) as $r)if(mb_stripos($r['name'].' '.$r['district'].' '.$r['address'],$q)!==false)$rows[]=['label'=>$r['name'].' — '.$r['district'],'latitude'=>$r['latitude'],'longitude'=>$r['longitude'],'district'=>$r['district']];
   echo json_encode(['results'=>array_slice($rows,0,8),'message'=>$message],JSON_UNESCAPED_UNICODE);
  }catch(InvalidArgumentException $e){http_response_code(422);echo json_encode(['error'=>$e->getMessage()]);}catch(Throwable $e){if(http_response_code()<400)http_response_code(503);echo json_encode(['error'=>$e instanceof RuntimeException?$e->getMessage():'Location lookup is unavailable. Please try again.']);}exit;
 }
}
