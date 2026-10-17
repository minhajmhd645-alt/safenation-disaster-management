param([int]$Port = 8090)
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$phpRuntime = 'D:\xampp\php\php.exe'
if (!(Test-Path -LiteralPath $phpRuntime)) { $phpRuntime = 'C:\xampp\php\php.exe' }
if (!(Test-Path -LiteralPath $phpRuntime)) { throw 'XAMPP PHP was not found. Update the runtime path in start-project.ps1.' }
Write-Host "Start MySQL in the XAMPP Control Panel. Open http://localhost:$Port in your browser."
& $phpRuntime -S "127.0.0.1:$Port" -t $projectRoot "$projectRoot\router.php"
