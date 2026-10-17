<?php
declare(strict_types=1);

function page_emergency_contacts(): void {
 $translations=[
  'en'=>['title'=>'Emergency Contacts','intro'=>'Find an emergency service and select its number to call.','back'=>'Back to Overview','language'=>'Language','search'=>'Search emergency contacts','placeholder'=>'Service name or telephone number','find'=>'Search','clear'=>'Show all','count'=>'Services found','empty'=>'No matching contacts','retry'=>'Try another service name or number.','numbers'=>'Telephone Number'],
  'si'=>['title'=>'හදිසි ඇමතුම් අංක','intro'=>'හදිසි සේවාවක් සොයා ඇමතුමක් ගැනීමට එහි දුරකථන අංකය තෝරන්න.','back'=>'මුල් පිටුවට ආපසු','language'=>'භාෂාව','search'=>'හදිසි ඇමතුම් අංක සොයන්න','placeholder'=>'සේවාවේ නම හෝ දුරකථන අංකය','find'=>'සොයන්න','clear'=>'සියල්ල පෙන්වන්න','count'=>'හමු වූ සේවා','empty'=>'ගැළපෙන සේවාවක් හමු නොවීය','retry'=>'වෙනත් සේවා නමක් හෝ අංකයක් යොදා සොයන්න.','numbers'=>'දුරකථන අංකය'],
  'ta'=>['title'=>'அவசர தொடர்பு எண்கள்','intro'=>'அவசர சேவையைக் கண்டறிந்து, அழைப்பதற்கு அதன் எண்ணைத் தேர்ந்தெடுக்கவும்.','back'=>'முகப்புப் பக்கத்திற்குத் திரும்பு','language'=>'மொழி','search'=>'அவசர தொடர்புகளைத் தேடுங்கள்','placeholder'=>'சேவையின் பெயர் அல்லது தொலைபேசி எண்','find'=>'தேடு','clear'=>'அனைத்தையும் காட்டு','count'=>'கண்டறியப்பட்ட சேவைகள்','empty'=>'பொருத்தமான தொடர்புகள் இல்லை','retry'=>'வேறொரு சேவையின் பெயர் அல்லது எண்ணைத் தேடுங்கள்.','numbers'=>'தொலைபேசி எண்'],
 ];
 $requested=$_GET['lang']??($_SESSION['contacts_language']??'en');
 $lang=is_string($requested)&&isset($translations[$requested])?$requested:'en';
 $_SESSION['contacts_language']=$lang;$t=$translations[$lang];
 $q=is_string($_GET['q']??null)?mb_substr(trim($_GET['q']),0,150):'';
 // One shared list keeps every telephone number identical in all languages.
 $contacts=json_decode(file_get_contents(dirname(__DIR__,2).'/config/emergency-contacts.json'),true,512,JSON_THROW_ON_ERROR);
 $matches=array_values(array_filter($contacts,static function(array $c)use($q):bool {
  if($q==='')return true;
  if(mb_stripos(implode(' ',array_values($c['names'])).' '.implode(' ',$c['numbers']),$q)!==false)return true;
  $digits=preg_replace('/\D/','',$q);
  if($digits!==''&&preg_match('/^[\d\s()+\-\/]+$/D',$q))foreach($c['numbers'] as $n)if(str_contains(preg_replace('/\D/','',$n),$digits))return true;
  return false;
 }));
 echo '<section class="emergency-directory" lang="'.e($lang).'">';
 heading($t['numbers'],$t['title'],$t['intro'],'<a class="button secondary" href="'.url('home').'">'.e($t['back']).'</a>');
 echo '<nav class="emergency-language" aria-label="'.e($t['language']).'">';
 foreach(['en'=>'English','si'=>'සිංහල','ta'=>'தமிழ்'] as $code=>$label)echo '<a class="button secondary small" lang="'.$code.'" hreflang="'.$code.'" '.($code===$lang?'aria-current="true"':'').' href="'.e(url('emergency-contacts',['lang'=>$code,'q'=>$q])).'">'.e($label).'</a>';
 echo '</nav><form class="filters emergency-search" method="get"><input type="hidden" name="page" value="emergency-contacts"><input type="hidden" name="lang" value="'.e($lang).'"><label class="field"><span>'.e($t['search']).'</span><input name="q" type="search" maxlength="150" value="'.e($q).'" placeholder="'.e($t['placeholder']).'"></label><button class="button">'.e($t['find']).'</button><a class="button secondary" href="'.e(url('emergency-contacts',['lang'=>$lang])).'">'.e($t['clear']).'</a></form>';
 echo '<p class="hint" role="status">'.e($t['count']).': '.count($matches).'</p><div class="emergency-grid">';
 foreach($matches as $c){
  echo '<article class="card emergency-contact"><span class="portal-icon" aria-hidden="true">'.icon($c['icon']).'</span><h2>'.e($c['names'][$lang]).'</h2><div class="emergency-numbers" aria-label="'.e($t['numbers']).'">';
  foreach($c['numbers'] as $i=>$number){if($i)echo '<span aria-hidden="true"> / </span>';echo '<a dir="ltr" href="tel:'.e($number).'" aria-label="'.e($c['names'][$lang].': '.$number).'">'.icon('phone').'<span>'.e($number).'</span></a>';}
  echo '</div></article>';
 }
 echo '</div>';if(!$matches)empty_state($t['empty'],$t['retry']);echo '</section>';
}
