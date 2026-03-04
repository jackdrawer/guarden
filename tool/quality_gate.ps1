param(
    [switch]$NoPubGet
)

$ErrorActionPreference = "Stop"

if (-not $NoPubGet) {
    flutter pub get
}

flutter analyze
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

flutter test
exit $LASTEXITCODE
