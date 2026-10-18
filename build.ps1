param(
    [string]$SdkRoot = $env:ANDROID_HOME,
    [string]$BuildToolsPath,
    [string]$AndroidJar,
    [string]$KeyStore = '.signing/personal.jks',
    [string]$KeyAlias = 'screenoff'
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (!$SdkRoot) { $SdkRoot = $env:ANDROID_SDK_ROOT }
if (!$BuildToolsPath -and $SdkRoot) { $BuildToolsPath = Join-Path $SdkRoot 'build-tools/35.0.0' }
if (!$AndroidJar -and $SdkRoot) { $AndroidJar = Join-Path $SdkRoot 'platforms/android-35/android.jar' }
if (!$BuildToolsPath -or !$AndroidJar) { throw 'Set ANDROID_HOME or provide -BuildToolsPath and -AndroidJar. See README.md.' }
$bt = (Resolve-Path $BuildToolsPath).Path
$android = (Resolve-Path $AndroidJar).Path
if (!$env:SCREENOFF_STORE_PASSWORD) { throw 'Set SCREENOFF_STORE_PASSWORD for APK signing. See README.md.' }
function Check { if ($LASTEXITCODE -ne 0) { throw "Build failed: $LASTEXITCODE" } }
New-Item -ItemType Directory -Force build,build/classes,build/dex,dist | Out-Null
# Remove stale generated files; verify cleanup stays within the project.
$projectRoot = [IO.Path]::GetFullPath($PSScriptRoot)
foreach ($generatedDirectory in @('build/classes', 'build/dex')) {
    $generatedPath = [IO.Path]::GetFullPath((Join-Path $projectRoot $generatedDirectory))
    if (!$generatedPath.StartsWith($projectRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe cleanup path' }
    Get-ChildItem -LiteralPath $generatedPath -File -Recurse | Remove-Item -Force
}
& "$bt/aapt2.exe" compile --dir res -o build/resources.zip
Check
& "$bt/aapt2.exe" link -o build/base.apk -I $android --manifest AndroidManifest.xml build/resources.zip
Check
$sources = @(Get-ChildItem src -Filter *.java -Recurse | ForEach-Object FullName)
& javac -encoding UTF-8 --release 8 -classpath $android -d build/classes $sources
Check
$classes = @(Get-ChildItem build/classes -Filter *.class -Recurse | ForEach-Object FullName)
& "$bt/d8.bat" --release --min-api 28 --lib $android --output build/dex $classes
Check
Copy-Item build/base.apk build/unsigned.apk -Force
& jar uf build/unsigned.apk -C build/dex classes.dex
Check
& "$bt/zipalign.exe" -f 4 build/unsigned.apk build/aligned.apk
Check
if (!(Test-Path -LiteralPath $KeyStore)) {
    $keyDirectory = Split-Path -Parent ([IO.Path]::GetFullPath($KeyStore))
    New-Item -ItemType Directory -Force -Path $keyDirectory | Out-Null
    & keytool -genkeypair -keystore $KeyStore -storepass:env SCREENOFF_STORE_PASSWORD -keypass:env SCREENOFF_STORE_PASSWORD -alias $KeyAlias -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=Screen Off'
    Check
}
& "$bt/apksigner.bat" sign --ks $KeyStore --ks-key-alias $KeyAlias --ks-pass env:SCREENOFF_STORE_PASSWORD --key-pass env:SCREENOFF_STORE_PASSWORD --out dist/ScreenOff.apk build/aligned.apk
Check
& "$bt/apksigner.bat" verify --verbose dist/ScreenOff.apk
Check
& "$bt/zipalign.exe" -c 4 dist/ScreenOff.apk
Check
Get-Item dist/ScreenOff.apk | Select-Object FullName,Length
