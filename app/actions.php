<?php
declare(strict_types=1);
function handle_action(): void {
 check_csrf();$action=(string)($_POST['action']??'');
 if($action==='login') {
  $portal=selected_portal();
  if($portal&&isset($_SESSION['uid'])&&user()){need_login();if(user()['role']===$portal)go('dashboard');throw new InvalidArgumentException('Sign out before accessing a different portal.');}

  $email=strtolower(txt('email',3,190));$fp=hash('sha256',($_SERVER['REMOTE_ADDR']??'').'|'.$email);
  if((int)scalar('SELECT COUNT(*) FROM login_attempts WHERE fingerprint=? AND created_at>DATE_SUB(NOW(),INTERVAL 15 MINUTE)',[$fp])>=8)throw new InvalidArgumentException('Too many sign-in attempts. Try again in 15 minutes.');
  $u=one('SELECT * FROM users WHERE email=? AND active=1',[$email]);
  if(!$u || !password_verify((string)($_POST['password']??''),$u['password_hash'])) {query('INSERT INTO login_attempts(fingerprint) VALUES(?)',[$fp]);throw new InvalidArgumentException('Email or password is incorrect.');}
  if($portal&&$u['role']!==$portal)throw new InvalidArgumentException('This account is not assigned to the selected portal. Choose your portal or use standard sign in.');
  session_regenerate_id(true);$_SESSION['uid']=$u['id'];$_SESSION['last_seen']=time();unset($_SESSION['csrf']);query('DELETE FROM login_attempts WHERE fingerprint=?',[$fp]);audit('signed_in','users',(int)$u['id']);go('dashboard');
 }
 if($action==='register') {
  $name=txt('name',2,100);$email=strtolower(txt('email',3,190));if(!filter_var($email,FILTER_VALIDATE_EMAIL))throw new InvalidArgumentException('Enter a valid email address.');
  $pw=txt('password',12,72);if($pw!==($_POST['confirm_password']??''))throw new InvalidArgumentException('Passwords do not match.');
  if(!isset($_POST['consent']))throw new InvalidArgumentException('Please acknowledge the privacy notice.');
  if(one('SELECT id FROM users WHERE email=?',[$email]))throw new InvalidArgumentException('This email is already registered.');
  $role=choice('role',['citizen','volunteer']);$phone=txt('phone',0,30);$area=txt('area',2,100);
  query('INSERT INTO users(name,email,password_hash,role,phone,area) VALUES(?,?,?,?,?,?)',[$name,$email,password_hash($pw,PASSWORD_DEFAULT),$role,$phone,$area]);
  session_regenerate_id(true);$_SESSION['uid']=(int)db()->lastInsertId();$_SESSION['last_seen']=time();unset($_SESSION['csrf']);audit('registered','users',(int)$_SESSION['uid']);flash('Your account is ready.');go($role==='volunteer'?'volunteers':'dashboard');
 }
 need_login();$uid=(int)user()['id'];
 if($action==='logout') {audit('signed_out','users',$uid);session_unset();session_regenerate_id(true);go('home');}
 db()->beginTransaction();
 try {
  switch($action) {
   case 'profile':
    $name=txt('name',2,100);$phone=txt('phone',0,30);$area=txt('area',2,100);
    query('UPDATE users SET name=?,phone=?,area=? WHERE id=?',[$name,$phone,$area,$uid]);
    if(($_POST['new_password']??'')!=='') {if(!password_verify((string)($_POST['current_password']??''),user()['password_hash']))throw new InvalidArgumentException('Current password is incorrect.');$pw=txt('new_password',12,72);if($pw!==($_POST['confirm_password']??''))throw new InvalidArgumentException('New passwords do not match.');query('UPDATE users SET password_hash=? WHERE id=?',[password_hash($pw,PASSWORD_DEFAULT),$uid]);session_regenerate_id(true);}
    audit('profile_updated','users',$uid);$next='profile';break;
   case 'report':
    [$lat,$lng]=coords();$type=type_id();$title=txt('title',5,150);$desc=txt('description',20,5000);$area=location_area($lat,$lng,null);$occur=dt('occurred_at');if(strtotime($occur)>time()+300)throw new InvalidArgumentException('An incident cannot occur in the future.');
    $people=integer('affected_people',0,1000000);$damage=choice('damage',['none','minor','moderate','severe']);$t=one('SELECT name FROM disaster_types WHERE id=?',[$type]);$ai=Severity::classify($t['name'],$desc,$people,$damage);
    query('INSERT INTO reports(user_id,type_id,title,description,area,latitude,longitude,occurred_at,affected_people,damage,ai_severity,ai_reason,severity) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)',[$uid,$type,$title,$desc,$area,$lat,$lng,$occur,$people,$damage,$ai['level'],$ai['reason'],$ai['level']]);$id=(int)db()->lastInsertId();
    if(array_key_exists('address',$_POST))query('UPDATE reports SET address=? WHERE id=?',[txt('address',0,255),$id]);
    audit('report_submitted','reports',$id);notify_coordinators('New incident report',"Report #$id awaits verification.",url('report',['id'=>$id]));$next='report';$args=['id'=>$id];break;
   case 'review':
    need('coordinate');$id=integer('id',1,PHP_INT_MAX);$r=one('SELECT * FROM reports WHERE id=? FOR UPDATE',[$id]);if(!$r)throw new InvalidArgumentException('Report not found.');
    $status=choice('status',['pending','verified','rejected','duplicate','merged','resolved']);if(!in_array($status,['verified','resolved'],true)&&scalar('SELECT COUNT(*) FROM reports WHERE duplicate_of=?',[$id]))throw new InvalidArgumentException('Reports linked as canonical incidents must remain verified or resolved.');$severity=choice('severity',['Low','Medium','High','Critical']);$note=txt('note',5,3000);$target=null;
    if(in_array($status,['duplicate','merged'],true)) {$target=integer('duplicate_of',1,PHP_INT_MAX);$parent=one("SELECT * FROM reports WHERE id=? AND status IN ('verified','resolved') FOR UPDATE",[$target]);if(!$parent || $target===$id)throw new InvalidArgumentException('Select a different verified or resolved incident as the canonical report.');if(scalar('SELECT COUNT(*) FROM reports WHERE duplicate_of=?',[$id]))throw new InvalidArgumentException('This report has linked duplicates. Keep it canonical.');}
    query('UPDATE reports SET status=?,severity=?,duplicate_of=? WHERE id=?',[$status,$severity,$target,$id]);query('INSERT INTO report_reviews(report_id,reviewer_id,status,severity,note) VALUES(?,?,?,?,?)',[$id,$uid,$status,$severity,$note]);
    notify((int)$r['user_id'],'Report status updated',"Report #$id is now $status. $note",url('report',['id'=>$id]));audit('report_reviewed','reports',$id,"$status / $severity / $note");$next='report';$args=['id'=>$id];break;
   case 'report_edit':
    need('coordinate');$id=integer('id',1,PHP_INT_MAX);$r=one('SELECT * FROM reports WHERE id=? FOR UPDATE',[$id]);if(!$r)throw new InvalidArgumentException('Report not found.');
    [$lat,$lng]=coords();$type=type_id();$title=txt('title',5,150);$desc=txt('description',20,5000);$area=location_area($lat,$lng,$r);$occur=dt('occurred_at');if(strtotime($occur)>time()+300)throw new InvalidArgumentException('An incident cannot occur in the future.');$people=integer('affected_people',0,1000000);$damage=choice('damage',['none','minor','moderate','severe']);$note=txt('note',5,3000);$t=one('SELECT name FROM disaster_types WHERE id=?',[$type]);$ai=Severity::classify($t['name'],$desc,$people,$damage);
    query('UPDATE reports SET type_id=?,title=?,description=?,area=?,latitude=?,longitude=?,occurred_at=?,affected_people=?,damage=?,ai_severity=?,ai_reason=? WHERE id=?',[$type,$title,$desc,$area,$lat,$lng,$occur,$people,$damage,$ai['level'],$ai['reason'],$id]);query('INSERT INTO report_reviews(report_id,reviewer_id,status,severity,note) VALUES(?,?,?,?,?)',[$id,$uid,$r['status'],$r['severity'],'Incident details updated: '.$note]);notify((int)$r['user_id'],'Incident details updated',"Report #$id: $note",url('report',['id'=>$id]));if(array_key_exists('address',$_POST))query('UPDATE reports SET address=? WHERE id=?',[txt('address',0,255),$id]);audit('report_details_updated','reports',$id,$note);$next='report';$args=['id'=>$id];break;
   case 'response':
    need('respond');$id=integer('id',1,PHP_INT_MAX);$r=one("SELECT * FROM reports WHERE id=? AND status='verified' FOR UPDATE",[$id]);if(!$r)throw new InvalidArgumentException('Only verified active incidents can receive response updates.');$status=choice('response_status',['monitoring','dispatched','on_scene','contained']);$note=txt('note',5,3000);
    query('UPDATE reports SET response_status=? WHERE id=?',[$status,$id]);audit('response_updated','reports',$id,"$status: $note");notify((int)$r['user_id'],'Response update',"Report #$id: $status. $note",url('report',['id'=>$id]));$next='report';$args=['id'=>$id];break;
   case 'alert':
    need('coordinate');$title=txt('title',5,150);$message=txt('message',20,5000);$area=txt('area',2,100);$severity=choice('severity',['Low','Medium','High','Critical']);$type=type_id();$expiry=dt('expires_at',true);if($expiry && strtotime($expiry)<=time())throw new InvalidArgumentException('Expiry must be in the future.');
    query('INSERT INTO alerts(author_id,type_id,title,message,area,severity,expires_at) VALUES(?,?,?,?,?,?,?)',[$uid,$type,$title,$message,$area,$severity,$expiry]);$id=(int)db()->lastInsertId();foreach(all('SELECT id FROM users WHERE active=1') as $u)notify((int)$u['id'],$title,$message,url('alerts'));audit('alert_published','alerts',$id);$next='alerts';break;
   case 'archive_alert':
    need('coordinate');$id=integer('id',1,PHP_INT_MAX);query('UPDATE alerts SET active=0 WHERE id=?',[$id]);audit('alert_archived','alerts',$id);$next='alerts';break;
   case 'facility':
    need('facilities');$id=integer('id',0,PHP_INT_MAX);$old=$id?one('SELECT * FROM facilities WHERE id=? FOR UPDATE',[$id]):null;
    if($id&&!$old)throw new InvalidArgumentException('Facility not found.');
    if(!can('coordinate') && (!$old || (int)$old['manager_id']!==$uid))throw new InvalidArgumentException('You can only update facilities assigned to your account.');
    [$lat,$lng]=coords();$kind=choice('kind',['shelter','hospital']);$name=txt('name',3,150);$area=location_area($lat,$lng,$old);$address=txt('address',5,255);$capacity=integer('capacity',0,1000000);$occupancy=integer('occupancy',0,1000000);if($occupancy>$capacity)throw new InvalidArgumentException('Occupancy cannot exceed capacity.');$services=txt('services',3,3000);$phone=txt('phone',3,30);$emergency=isset($_POST['emergency_service'])?1:0;$status=choice('status',['open','limited','closed','unknown']);$capacityKnown=isset($_POST['capacity_unknown'])?0:1;if(!in_array($area,districts(),true)&&$area!==($old['area']??null))throw new InvalidArgumentException('Select a valid Sri Lankan district.');$manager=$old['manager_id']??null;
    if(can('coordinate')) {$m=integer('manager_id',0,PHP_INT_MAX);$manager=$m?:null;if($manager&&!one("SELECT id FROM users WHERE id=? AND role='facility_manager' AND active=1",[$manager]))throw new InvalidArgumentException('Select an active facility manager.');}
    $vals=[$manager,$kind,$name,$area,$address,$lat,$lng,$capacity,$occupancy,$services,$phone,$emergency,$status];
    if($id)query('UPDATE facilities SET manager_id=?,kind=?,name=?,area=?,address=?,latitude=?,longitude=?,capacity=?,occupancy=?,services=?,phone=?,emergency_service=?,status=? WHERE id=?',[...$vals,$id]);else{query('INSERT INTO facilities(manager_id,kind,name,area,address,latitude,longitude,capacity,occupancy,services,phone,emergency_service,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)',$vals);$id=(int)db()->lastInsertId();}
    query('UPDATE facilities SET capacity_known=? WHERE id=?',[$capacityKnown,$id]);
    audit('facility_saved','facilities',$id);$next='facilities';break;
   case 'assistance':
    [$lat,$lng]=coords();$category=choice('category',['Medical assistance','Evacuation support','Food and water','Shelter','Rescue assistance','Other']);$desc=txt('description',20,5000);$area=location_area($lat,$lng,null);$people=integer('people',1,1000000);
    query("INSERT INTO assistance_requests(user_id,category,description,area,latitude,longitude,people,note) VALUES(?,?,?,?,?,?,?,'')",[$uid,$category,$desc,$area,$lat,$lng,$people]);$id=(int)db()->lastInsertId();notify_coordinators('New assistance request',"Request #$id needs review.",url('assistance'));if(array_key_exists('address',$_POST))query('UPDATE assistance_requests SET address=? WHERE id=?',[txt('address',0,255),$id]);audit('assistance_submitted','assistance_requests',$id);$next='assistance';break;
   case 'request_update':
    need('respond');$id=integer('id',1,PHP_INT_MAX);$r=one('SELECT * FROM assistance_requests WHERE id=? FOR UPDATE',[$id]);if(!$r)throw new InvalidArgumentException('Request not found.');if(!can('coordinate') && (int)$r['assigned_to']!==$uid)throw new InvalidArgumentException('Only requests assigned to you can be updated.');$status=choice('status',['submitted','reviewing','assigned','in_progress','fulfilled','cancelled']);$note=txt('note',5,3000);$assignee=$r['assigned_to'];
    if(can('coordinate')) {$a=integer('assigned_to',0,PHP_INT_MAX);$assignee=$a?:null;if($assignee&&!one("SELECT id FROM users WHERE id=? AND role IN ('authority','responder','admin') AND active=1",[$assignee]))throw new InvalidArgumentException('Select an active response team member.');}
    if(in_array($status,['assigned','in_progress'],true)&&!$assignee)throw new InvalidArgumentException('Assign a response team member first.');
    query('UPDATE assistance_requests SET status=?,assigned_to=?,note=? WHERE id=?',[$status,$assignee,$note,$id]);notify((int)$r['user_id'],'Assistance request updated',"Request #$id: $status. $note",url('assistance'));if($assignee)notify((int)$assignee,'Assistance assignment',"Request #$id: $status. $note",url('assistance'));audit('request_updated','assistance_requests',$id,"$status: $note");$next='assistance';break;
   case 'volunteer_profile':
    $skills=txt('skills',3,255);$experience=txt('experience',0,3000);$availability=choice('availability',['available','limited','unavailable']);$area=txt('service_area',2,100);
    query('INSERT INTO volunteers(user_id,skills,experience,availability,service_area) VALUES(?,?,?,?,?) ON DUPLICATE KEY UPDATE skills=VALUES(skills),experience=VALUES(experience),availability=VALUES(availability),service_area=VALUES(service_area)',[$uid,$skills,$experience,$availability,$area]);audit('volunteer_profile_saved','volunteers',$uid);$next='volunteers';break;
   case 'assignment':
    need('coordinate');$v=integer('volunteer_id',1,PHP_INT_MAX);if(!one("SELECT v.user_id FROM volunteers v JOIN users u ON u.id=v.user_id WHERE v.user_id=? AND v.availability<>'unavailable' AND u.active=1",[$v]))throw new InvalidArgumentException('Select an available active volunteer.');$rid=integer('report_id',0,PHP_INT_MAX);if($rid&&!one("SELECT id FROM reports WHERE id=? AND status='verified'",[$rid]))throw new InvalidArgumentException('Select a verified active incident.');$title=txt('title',5,150);$instructions=txt('instructions',10,3000);$area=txt('area',2,100);$due=dt('due_at');if(strtotime($due)<=time())throw new InvalidArgumentException('Assignment due time must be in the future.');
    query('INSERT INTO volunteer_assignments(volunteer_id,report_id,coordinator_id,title,instructions,area,due_at) VALUES(?,?,?,?,?,?,?)',[$v,$rid?:null,$uid,$title,$instructions,$area,$due]);$id=(int)db()->lastInsertId();notify($v,'Volunteer assignment',$title,url('volunteers'));audit('volunteer_assigned','volunteer_assignments',$id);$next='volunteers';break;
   case 'assignment_update':
    $id=integer('id',1,PHP_INT_MAX);$a=one('SELECT * FROM volunteer_assignments WHERE id=? FOR UPDATE',[$id]);if(!$a||(!can('coordinate')&&(int)$a['volunteer_id']!==$uid))throw new InvalidArgumentException('Assignment not accessible.');$allowed=can('coordinate')?['assigned','accepted','in_progress','completed','declined','cancelled']:['accepted','in_progress','completed','declined'];$status=choice('status',$allowed);
    $transitions=['assigned'=>['accepted','declined'],'accepted'=>['in_progress','declined'],'in_progress'=>['completed']];if(!can('coordinate')&&!in_array($status,$transitions[$a['status']]??[],true))throw new InvalidArgumentException('This assignment status transition is not allowed.');
    query('UPDATE volunteer_assignments SET status=? WHERE id=?',[$status,$id]);notify((int)$a['coordinator_id'],'Assignment status updated',"Assignment #$id: $status",url('volunteers'));audit('assignment_updated','volunteer_assignments',$id,$status);$next='volunteers';break;
   case 'resource':
    need('coordinate');$name=txt('name',3,100);$cat=choice('category',['Food','Water','Medicine','Equipment','Transport','Other']);$unit=txt('unit',1,30);$loc=txt('location',2,100);$min=number('minimum_quantity',0,10000000);
    query('INSERT INTO resources(name,category,unit,location,minimum_quantity) VALUES(?,?,?,?,?)',[$name,$cat,$unit,$loc,$min]);$id=(int)db()->lastInsertId();audit('resource_created','resources',$id);$next='resources';break;
   case 'stock':
    need('coordinate');$id=integer('resource_id',1,PHP_INT_MAX);$r=one('SELECT * FROM resources WHERE id=? FOR UPDATE',[$id]);if(!$r)throw new InvalidArgumentException('Resource not found.');$kind=choice('kind',['received','distributed','transfer']);$qty=number('quantity',0.01,10000000);$destination=txt('destination',2,150);$note=txt('note',3,3000);
    $new=(float)$r['quantity']+($kind==='received'?$qty:-$qty);if($new<0)throw new InvalidArgumentException('Insufficient stock. No distribution has been recorded.');
    if($kind==='transfer') {$target=integer('target_resource_id',1,PHP_INT_MAX);if($target===$id)throw new InvalidArgumentException('Choose a different destination inventory item.');$t=one('SELECT * FROM resources WHERE id=? FOR UPDATE',[$target]);if(!$t||$t['name']!==$r['name']||$t['unit']!==$r['unit'])throw new InvalidArgumentException('Transfer destination must have the same item name and unit.');query('UPDATE resources SET quantity=quantity+? WHERE id=?',[$qty,$target]);query('INSERT INTO resource_transactions(resource_id,user_id,kind,quantity,destination,note) VALUES(?,?,?,?,?,?)',[$target,$uid,'received',$qty,$t['location'],'Transfer from '.$r['location'].': '.$note]);}
    query('UPDATE resources SET quantity=? WHERE id=?',[$new,$id]);query('INSERT INTO resource_transactions(resource_id,user_id,kind,quantity,destination,note) VALUES(?,?,?,?,?,?)',[$id,$uid,$kind,$qty,$destination,$note]);audit('resource_'.$kind,'resources',$id,"$qty {$r['unit']} / $destination");$next='resources';break;
   case 'notifications_read':
    query('UPDATE notifications SET read_at=NOW() WHERE user_id=? AND read_at IS NULL',[$uid]);$next='notifications';break;
   case 'user_update':
    need('admin');$id=integer('id',1,PHP_INT_MAX);$r=one('SELECT * FROM users WHERE id=? FOR UPDATE',[$id]);if(!$r)throw new InvalidArgumentException('User not found.');$role=choice('role',['citizen','volunteer','authority','responder','facility_manager','admin']);$active=integer('active',0,1);if($id===$uid&&($role!=='admin'||!$active))throw new InvalidArgumentException('You cannot remove your own administrator access.');
    if($r['role']==='admin'&&($role!=='admin'||!$active)&&(int)scalar("SELECT COUNT(*) FROM users WHERE role='admin' AND active=1")<=1)throw new InvalidArgumentException('At least one active administrator must remain.');
    query('UPDATE users SET role=?,active=? WHERE id=?',[$role,$active,$id]);audit('account_updated','users',$id,"$role / active=$active");$next='users';break;
   case 'settings':
    need('admin');$name=txt('site_name',3,60);$announcement=txt('announcement',0,500);query("UPDATE settings SET value=? WHERE name='site_name'",[$name]);query("UPDATE settings SET value=? WHERE name='announcement'",[$announcement]);audit('settings_updated','settings');$next='settings';break;
   default:throw new InvalidArgumentException('Unknown form action.');
  }
  db()->commit();flash('Saved successfully.');go($next,$args??[]);
 }catch(Throwable $ex){if(db()->inTransaction())db()->rollBack();throw $ex;}
}
