param(
    [string]$Src   = "D:\mp sound file",
    [string]$Dest  = "D:\iot\iTK50-Sound\sound",
    [string]$RepoPrefix = "sound"
)

$ErrorActionPreference = 'Stop'

# explicit mapping: original relative path -> published file name + display title
$map = @(
    @{ src = 'V3\CEN\CEN V3.raw';                      file = 'cen_v3f.raw';              title = 'CEN V3F' },
    @{ src = 'V3\CH2\CH2 V3_3.raw';                    file = 'ch2_v3f.raw';              title = 'CH2 V3F' },
    @{ src = 'V3\Churchill\chu V3.raw';                file = 'churchill_v3f.raw';        title = 'Churchill V3F' },
    @{ src = 'V3\GE\GE V3.raw';                        file = 'ge_v3f.raw';               title = 'GE V3F' },
    @{ src = 'V3\JS2\JS2 V3 from T90.raw';             file = 'js2_v3f.raw';              title = 'JS2 V3F' },
    @{ src = 'V3\KT\KT V3.raw';                        file = 'kt_v3f.raw';               title = 'KT V3F' },
    @{ src = 'V3\L1\L1 V3.raw';                        file = 'l1_v3f.raw';               title = 'L1 V3F' },
    @{ src = 'V3\L2\L2 V3.raw';                        file = 'l2_v3f.raw';               title = 'L2 V3F' },
    @{ src = 'V3\M1\M1 V3 release 1.raw';              file = 'm1_v3f.raw';               title = 'M1 V3F' },
    @{ src = 'V3\M18\M18 V3 release 1.raw';            file = 'm18_v3f.raw';              title = 'M18 V3F' },
    @{ src = 'V3\M2 Bradley\M2 V3.raw';                file = 'm2_bradley_v3f.raw';       title = 'M2 Bradley V3F' },
    @{ src = 'V3\M60\M60 V3 release 1 L2 turret.raw';  file = 'm60_v3f_v2_l2_turret.raw'; title = 'M60 V3F V2(L2 turret)' },
    @{ src = 'V3\M60\M60 V3 release 1.raw';            file = 'm60_v3f_v1.raw';           title = 'M60 V3F V1' },
    @{ src = 'V3\Nashorn\PZ4 Nashorn V3.raw';          file = 'nashorn_pz4_v3.raw';       title = 'Nashorn PZ4 V3' },
    @{ src = 'V3\Stian\l1v3newgunsounds.raw';          file = 'l1_v3f_v1_new_gun.raw';    title = 'L1 V3F V1 new gun' },
    @{ src = 'V3\Stian\l1v3noturbotest.raw';           file = 'l1_v3f_v2_no_turbo.raw';   title = 'L1 V3F V2 no turbo' },
    @{ src = 'V3\T1\T1 V3.raw';                        file = 't1_v3f.raw';               title = 'T1 V3F' },
    @{ src = 'V3\T90\T90 V3.raw';                      file = 't90_v3f.raw';              title = 'T-90 V3F' }
)

if (-not (Test-Path -LiteralPath $Dest)) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }

$entries = @()
foreach ($m in $map) {
    $sp = Join-Path $Src $m.src
    if (-not (Test-Path -LiteralPath $sp)) { throw "missing source: $sp" }
    $dp = Join-Path $Dest $m.file
    Copy-Item -LiteralPath $sp -Destination $dp -Force
    $len = (Get-Item -LiteralPath $dp).Length
    $sha = (Get-FileHash -LiteralPath $dp -Algorithm SHA256).Hash.ToLower()
    $entries += [ordered]@{
        file   = "$RepoPrefix/$($m.file)"
        title  = $m.title
        size   = [int64]$len
        sha256 = $sha
        source = $m.src -replace '\\', '/'
    }
    "copied {0,-24} {1,10:N0} bytes" -f $m.file, $len
}

$total = ($entries | ForEach-Object { $_.size } | Measure-Object -Sum).Sum

$manifest = [ordered]@{
    schema   = 'itk50-sound-manifest'
    version  = '1.0'
    repo     = 'sword77777/iTK50-Sound'
    branch   = 'main'
    base_url = 'https://raw.githubusercontent.com/sword77777/iTK50-Sound/main/'
    entry    = 'sound/manifest.json'
    updated  = (Get-Date -Format 'yyyy-MM-dd')
    format   = 'raw 8-bit PCM stream, 4 MB address space, M25P32 SPI flash image'
    count    = $entries.Count
    total_size = [int64]$total
    files    = $entries
}

$json = $manifest | ConvertTo-Json -Depth 4
[IO.File]::WriteAllText((Join-Path $Dest 'manifest.json'), $json + "`n", (New-Object Text.UTF8Encoding($false)))

"--- manifest.json written: $($entries.Count) files, total $('{0:N0}' -f $total) bytes ---"
