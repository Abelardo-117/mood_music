$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$manifestPath = Join-Path $root 'android\app\src\main\AndroidManifest.xml'
if (!(Test-Path $manifestPath)) { throw 'Copia este script a C:\mood_music y ejecutalo desde ahi.' }
$android = 'http://schemas.android.com/apk/res/android'
[xml]$doc = Get-Content -Raw $manifestPath
$ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
$ns.AddNamespace('android', $android)
$app = $doc.SelectSingleNode('/manifest/application')
if ($null -eq $app) { throw 'No se encontro application en el manifiesto.' }
$activity = $doc.SelectSingleNode('/manifest/application/activity[intent-filter/action[@android:name="android.intent.action.MAIN"]]', $ns)
if ($null -eq $activity) { throw 'No se encontro la actividad principal. Envia tu AndroidManifest.xml para revisarlo.' }
$activityName = $activity.GetAttribute('name', $android)
$activityPath = $null
$activityText = $null
if ($activityName -ne 'com.ryanheise.audioservice.AudioServiceActivity') {
  if (!$activityName.EndsWith('MainActivity')) { throw 'Actividad personalizada. Envia AndroidManifest.xml y tu Activity para adaptar el cambio.' }
  $candidates = @(Get-ChildItem (Join-Path $root 'android\app\src\main') -Recurse -File | Where-Object { $_.Name -eq 'MainActivity.kt' -or $_.Name -eq 'MainActivity.java' })
  if ($candidates.Count -ne 1) { throw 'No se encontro una unica MainActivity. Envia ese archivo para revisarlo.' }
  $activityPath = $candidates[0].FullName
  $activityText = [IO.File]::ReadAllText($activityPath)
  if ($activityText.Contains('io.flutter.embedding.android.FlutterFragmentActivity')) {
    $activityText = $activityText.Replace('io.flutter.embedding.android.FlutterFragmentActivity', 'com.ryanheise.audioservice.AudioServiceFragmentActivity')
    $activityText = [regex]::Replace($activityText, '\bFlutterFragmentActivity\b', 'AudioServiceFragmentActivity')
  } elseif ($activityText.Contains('io.flutter.embedding.android.FlutterActivity')) {
    $activityText = $activityText.Replace('io.flutter.embedding.android.FlutterActivity', 'com.ryanheise.audioservice.AudioServiceActivity')
    $activityText = [regex]::Replace($activityText, '\bFlutterActivity\b', 'AudioServiceActivity')
  } elseif (!$activityText.Contains('com.ryanheise.audioservice.AudioService')) {
    throw 'MainActivity no tiene la estructura esperada. No se modifico ningun archivo.'
  }
}
function Set-AndroidAttribute($element, $name, $value) {
  $attribute = $doc.CreateAttribute('android', $name, $android)
  $attribute.Value = $value
  [void]$element.Attributes.SetNamedItem($attribute)
}
foreach ($permission in @('WAKE_LOCK', 'FOREGROUND_SERVICE', 'FOREGROUND_SERVICE_MEDIA_PLAYBACK')) {
  $full = 'android.permission.' + $permission
  if ($null -eq $doc.SelectSingleNode("/manifest/uses-permission[@android:name='$full']", $ns)) {
    $node = $doc.CreateElement('uses-permission')
    Set-AndroidAttribute $node 'name' $full
    [void]$doc.DocumentElement.InsertBefore($node, $app)
  }
}
foreach ($entry in @(
  @{ Tag='service'; Name='com.ryanheise.audioservice.AudioService'; Action='android.media.browse.MediaBrowserService' },
  @{ Tag='receiver'; Name='com.ryanheise.audioservice.MediaButtonReceiver'; Action='android.intent.action.MEDIA_BUTTON' }
)) {
  $node = $doc.SelectSingleNode("/manifest/application/$($entry.Tag)[@android:name='$($entry.Name)']", $ns)
  if ($null -eq $node) { $node = $doc.CreateElement($entry.Tag); [void]$app.AppendChild($node) }
  Set-AndroidAttribute $node 'name' $entry.Name
  Set-AndroidAttribute $node 'exported' 'true'
  if ($entry.Tag -eq 'service') { Set-AndroidAttribute $node 'foregroundServiceType' 'mediaPlayback' }
  if ($null -eq $node.SelectSingleNode("intent-filter/action[@android:name='$($entry.Action)']", $ns)) {
    $filter = $doc.CreateElement('intent-filter'); $action = $doc.CreateElement('action')
    Set-AndroidAttribute $action 'name' $entry.Action
    [void]$filter.AppendChild($action); [void]$node.AppendChild($filter)
  }
}
$backup = Join-Path $root ('respaldo_audio_android_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
[void](New-Item -ItemType Directory -Path $backup)
Copy-Item $manifestPath (Join-Path $backup 'AndroidManifest.xml')
if ($null -ne $activityPath) {
  Copy-Item $activityPath (Join-Path $backup ([IO.Path]::GetFileName($activityPath)))
  [IO.File]::WriteAllText($activityPath, $activityText, (New-Object Text.UTF8Encoding($false)))
}
$doc.Save($manifestPath)
Write-Host 'Listo: servicio de audio configurado. Reinicia con flutter run; hot reload no basta.'
Write-Host "Respaldo: $backup"
