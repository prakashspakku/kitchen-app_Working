Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Command {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name
  )
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

function Write-Ok {
  param([string]$Message)
  Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-WarnMsg {
  param([string]$Message)
  Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

Write-Host "==> Kitchen App preflight checks (PowerShell)" -ForegroundColor Cyan

Assert-Command git
Assert-Command node
Assert-Command npm
Assert-Command docker
Assert-Command kubectl
Assert-Command curl.exe

$gitVersion = git --version
Write-Ok $gitVersion

$nodeVersion = node --version
Write-Ok "Node $nodeVersion"

$npmVersion = npm --version
Write-Ok "npm $npmVersion"

$dockerVersion = docker --version
Write-Ok $dockerVersion

$composeVersion = docker compose version
Write-Ok $composeVersion

$kctlVersion = kubectl version --client --output=yaml
if ($LASTEXITCODE -ne 0) {
  throw "kubectl client check failed"
}
Write-Ok "kubectl client available"

$context = kubectl config current-context
if ([string]::IsNullOrWhiteSpace($context)) {
  throw "kubectl has no active context"
}
Write-Ok "kubectl context: $context"

$nodes = kubectl get nodes --no-headers 2>$null
if ([string]::IsNullOrWhiteSpace($nodes)) {
  Write-WarnMsg "No Kubernetes nodes found. Enable Kubernetes in Docker Desktop."
} else {
  Write-Ok "Kubernetes nodes detected"
}

$requiredPorts = @(3000, 8080, 27017, 30000, 30080, 30090, 30300)
foreach ($port in $requiredPorts) {
  $inUse = netstat -ano | Select-String ":$port "
  if ($inUse) {
    Write-WarnMsg "Port $port appears in use. Stop conflicting app before running workshop steps."
  } else {
    Write-Ok "Port $port is available"
  }
}

Write-Host ""
Write-Host "Preflight completed." -ForegroundColor Cyan
Write-Host "If warnings were shown, fix them before continuing." -ForegroundColor Cyan
