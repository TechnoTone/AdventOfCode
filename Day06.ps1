
$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day06.data)

function location ($x,$y) {
    [PSCustomObject]@{x=[int]($x);y=[int]($y);finite=$true}
}

function dist ($p1,$p2) {
    [Math]::Abs($p1.x-$p2.x) + [Math]::Abs($p1.y-$p2.y)
}

function closestPoints($p) {
    $dist = @(0) * $data.Count
    for ($i = 0; $i -lt $data.Count; $i++) {
        $dist[$i] = dist $p $data[$i]
    }
    $smallest = $dist | sort | select -First 1
    for ($i = 0; $i -lt $data.Count; $i++) {
        if ($dist[$i] -eq $smallest) {
            $data[$i]
        }
    }
}

function closestTo($p) {
    return $data.IndexOf((closestPoints $p)) #if ClosestPoints > 1 item then Indexof failes with -1 - PERFECT!
}

$data = $data | % {$xy = $_.Split(","); location $xy[0] $xy[1]}

$xOffset = $data.x | sort | select -First 1
$yOffset = $data.y | sort | select -First 1

$data | % {$_.x = $_.x-$xOffset; $_.y = $_.y-$yOffset}

$xMax = ($data.x | sort -Descending | select -First 1)
$yMax = ($data.y | sort -Descending | select -First 1)


# find infinite edges
foreach ($x in @(0..$xMax)) {
    (closestPoints(location $x 0)) | % {$_.finite=$false}
    (closestPoints(location $x $yMax)) | % {$_.finite=$false}
}
foreach ($y in @(0..$yMax)) {
    (closestPoints(location 0 $y)) | % {$_.finite=$false}
    (closestPoints(location $xMax $y)) | % {$_.finite=$false}
}


#Part 1

$start = Get-Date

$map = New-Object "Int[,]" ($xMax+1),($yMax+1)
$map2 = New-Object "Int[,]" ($xMax+1),($yMax+1)

foreach ($x in @(0..$xMax)) {
    foreach ($y in @(0..$yMax)) {
        $loc = location $x $y
        if (!($map[$x, $y])) {
            $map[$x,$y] = closestTo $loc
        }
        foreach ($p in $data) {
            $map2[$x,$y] += dist $p $loc
        }
    }
}

$answer = $map | ? {$data[$_].finite -and $_ -ge 0} | group -NoElement | sort -Descending Count | select -ExpandProperty Count -First 1


Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $answer,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$answer2 = ($map2 | ? {$_ -lt 10000}).Count

Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
