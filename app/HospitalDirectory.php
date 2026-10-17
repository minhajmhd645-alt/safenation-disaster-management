<?php
declare(strict_types=1);
/** Additive, repeatable import. Existing facilities and later edits are preserved. */
final class HospitalDirectory {
 public static function seed(PDO $pdo): int {
  $records=json_decode(file_get_contents(dirname(__DIR__).'/database/hospitals.json'),true,512,JSON_THROW_ON_ERROR);
  $find=$pdo->prepare('SELECT id FROM facilities WHERE source_code=? OR (kind=? AND name=? AND area=?) LIMIT 1');
  $insert=$pdo->prepare('INSERT INTO facilities(kind,name,area,address,latitude,longitude,capacity,occupancy,capacity_known,services,phone,emergency_service,status,source_code,source_url) VALUES(?,?,?,?,?,?,0,0,0,?,?,0,?,?,?)');
  $count=0;
  foreach($records as $r){
   $find->execute([$r['source_code'],'hospital',$r['name'],$r['district']]);
   if($find->fetchColumn())continue;
   $insert->execute(['hospital',$r['name'],$r['district'],$r['address'],$r['latitude'],$r['longitude'],'Government hospital directory. Contact the hospital to confirm current services, emergency access and bed availability.','Not recorded','unknown',$r['source_code'],$r['source_url']]);
   $count++;
  }
  return $count;
 }
}
