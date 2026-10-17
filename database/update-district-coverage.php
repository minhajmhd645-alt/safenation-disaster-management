<?php
declare(strict_types=1);
// Run with XAMPP PHP from the terminal; unavailable as a web endpoint.
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
require_once dirname(__DIR__).'/app/HospitalDirectory.php';
$c=require dirname(__DIR__).'/config/database.php';
$pdo=new PDO("mysql:host={$c['host']};port={$c['port']};dbname={$c['database']};charset=utf8mb4",$c['username'],$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
foreach(['capacity_known'=>'BOOLEAN NOT NULL DEFAULT 1','source_code'=>'VARCHAR(100) NULL UNIQUE','source_url'=>'VARCHAR(255) NULL'] as $column=>$definition){
 $check=$pdo->prepare('SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=? AND table_name=? AND column_name=?');$check->execute([$c['database'],'facilities',$column]);
 if(!$check->fetchColumn())$pdo->exec("ALTER TABLE facilities ADD COLUMN $column $definition");
}
$pdo->beginTransaction();
try{
 $added=HospitalDirectory::seed($pdo);
 $pdo->prepare("UPDATE settings SET value=? WHERE name='announcement' AND value IN (?,?)")->execute(['Our project includes labelled example records. Hospital directory availability must be confirmed with the hospital.','Our project includes labelled example records. Hospital directory availability must be confirmed with the hospital.','Our project includes labelled example records. Hospital directory availability must be confirmed with the hospital.']);
 if($added)$pdo->prepare('INSERT INTO audit_logs(action,entity,detail) VALUES(?,?,?)')->execute(['hospital_directory_imported','facilities',"Added $added hospital directory entries across 25 districts; existing records preserved."]);
 $pdo->commit();echo "Added $added hospitals.\n";
}catch(Throwable $e){$pdo->rollBack();throw $e;}
