# PROG5 — Vérification de l'environnement (Windows)
# Usage : powershell -ExecutionPolicy Bypass -File .\check-env.ps1
# Le résultat est aussi écrit dans check-env-result.txt, à pousser sur votre dépôt.

$JavaMin  = 21
$NodeMin  = 24
$PhpMinId = 80400        # PHP 8.4
$PgImage  = "postgres:17"
$Guide    = "https://hei-lms.app"
$Out      = "check-env-result.txt"

$script:Errors = 0
Set-Content -Path $Out -Value $null -Encoding utf8

function Log($m) { Write-Host $m; Add-Content -Path $Out -Value $m -Encoding utf8 }
function Ok($m)  { Log "[OK] $m" }
function Ko($m)  { Log "[KO] $m"; $script:Errors++ }
function Has($c) { [bool](Get-Command $c -ErrorAction SilentlyContinue) }
function Major($v) { if ("$v" -match '(\d+)') { [int]$Matches[1] } else { 0 } }
function Grab($cmd, $pattern) {
  $hit = & $cmd 2>&1 | ForEach-Object { "$_" } | Select-String -Pattern $pattern | Select-Object -First 1
  if ($hit) { $hit.Matches[0].Groups[1].Value } else { "?" }
}

Log "PROG5 — vérification de l'environnement"
Log ("Date    : " + (Get-Date -Format "yyyy-MM-dd HH:mm"))
Log ("Système : Windows " + [System.Environment]::OSVersion.Version)
Log ""

# 1. Git ------------------------------------------------------------------
if (-not (Has git)) { Ko "git : introuvable" }
else {
  $v = ((git --version) -split ' ')[2]
  $name  = git config --global user.name
  $email = git config --global user.email
  if (-not $name -or -not $email) { Ko "git $v : identité non configurée (git config --global user.name / user.email)" }
  else { Ok "git $v ($name <$email>)" }
}

# 2. Java + Maven ---------------------------------------------------------
if (-not (Has java)) { Ko "java : introuvable (JDK $JavaMin requis)" }
elseif (-not (Has mvn)) { Ko "mvn : introuvable" }
else {
  $jv = Grab { java -version } 'version "([^"]+)"'
  $mv = Grab { mvn -v } 'Apache Maven (\S+)'
  if ((Major $jv) -ge $JavaMin) { Ok "java $jv, mvn $mv" }
  else { Ko "java $jv : version trop ancienne (JDK $JavaMin requis)" }
}

# 3. Node.js + npm --------------------------------------------------------
if (-not (Has node)) { Ko "node : introuvable (Node.js $NodeMin LTS requis)" }
elseif (-not (Has npm)) { Ko "npm : introuvable" }
else {
  $nv = (node -v).Trim()
  $pv = (npm -v).Trim()
  if ((Major $nv) -ge $NodeMin) { Ok "node $nv, npm $pv" }
  else { Ko "node $nv : version trop ancienne (Node.js $NodeMin LTS requis)" }
}

# 4. PHP + Composer + Symfony CLI -----------------------------------------
if (-not (Has php)) { Ko "php : introuvable (PHP 8.4 requis)" }
elseif (-not (Has composer)) { Ko "composer : introuvable" }
elseif (-not (Has symfony)) { Ko "symfony : CLI introuvable" }
else {
  $id = [int](php -r "echo PHP_VERSION_ID;")
  $v  = php -r "echo PHP_VERSION;"
  $cv = Grab { composer --version } 'Composer version (\S+)'
  if ($id -lt $PhpMinId) { Ko "php $v : version trop ancienne (PHP 8.4 requis)" }
  else {
    symfony check:requirements *> $null
    if ($LASTEXITCODE -eq 0) { Ok "php $v, composer $cv, symfony" }
    else { Ko "php $v : extensions manquantes pour Symfony (lancez : symfony check:requirements)" }
  }
}

# 5. Docker + image PostgreSQL --------------------------------------------
if (-not (Has docker)) { Ko "docker : introuvable" }
else {
  docker info *> $null
  if ($LASTEXITCODE -ne 0) { Ko "docker : installé mais pas démarré (lancez Docker Desktop)" }
  else {
    docker image inspect $PgImage *> $null
    if ($LASTEXITCODE -ne 0) { Ko "docker OK, image $PgImage absente (lancez : docker pull $PgImage)" }
    else { Ok ("docker " + (docker version --format '{{.Server.Version}}') + ", image $PgImage") }
  }
}

Log ""
if ($script:Errors -eq 0) {
  Log "Environnement prêt pour PROG5"
  exit 0
} else {
  Log "$($script:Errors) point(s) à corriger avant la séance 2. Guide : $Guide"
  exit 1
}
