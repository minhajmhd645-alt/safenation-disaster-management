<?php
// Router for VS Code's XAMPP PHP development server. Apache uses .htaccess.
$path=rawurldecode(parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH)??'/');
if(preg_match('~^/(app|config|database|storage|tests|scripts|\.vscode)(/|$)|\.sql$|\.md$|\.ps1$|\.code-workspace$~i',$path)){http_response_code(403);exit('Private project path.');}
if($path==='/'||$path==='/index.php'){require __DIR__.'/index.php';return true;}
$file=realpath(__DIR__.$path);if($file&&str_starts_with($file,__DIR__.DIRECTORY_SEPARATOR)&&is_file($file)) {
 $relative=str_replace(DIRECTORY_SEPARATOR,'/',substr($file,strlen(__DIR__)+1));
 if($relative==='setup.php' || (str_starts_with($relative,'assets/') && in_array(strtolower(pathinfo($relative,PATHINFO_EXTENSION)),['css','js','svg','png','webp'],true)))return false;
 http_response_code(403);exit('Private project path.');
}
http_response_code(404);echo 'Page not found.';
