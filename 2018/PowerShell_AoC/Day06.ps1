

$start = Get-Date

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day06.data)

function location ($x,$y) {
    [PSCustomObject]@{x=[int]($x);y=[int]($y);d=$null;a=$null;finite=$true}
}

function dist ($p1,$p2) {
    [Math]::Abs($p1.x-$p2.x) + [Math]::Abs($p1.y-$p2.y)
}

function area ($r) {
    $r*$r*4
}

$data = $data | % {$xy = $_.Split(","); location $xy[0] $xy[1]}

function closestTo($p) {
    $r = $data[0]
    $d = 999
    foreach ($p2 in $data) {
        $d2 = dist $p $p2
        if ($d2 -lt $d) {$d = $d2;$r=$p2}
    }
    $r
}

#Part 1

foreach ($x in @(1..400)) {
    (closestTo(location 1 $x)).finite=$false
    (closestTo(location 400 $x)).finite=$false
    (closestTo(location $x 1)).finite=$false
    (closestTo(location $x 400)).finite=$false
}

foreach ($loc in $data) {
    foreach ($loc2 in $data) {
        if ($loc.x -ne $loc2.x -or $loc.y -ne $loc2.y) {
            $d = dist $loc $loc2
            if (!$loc.d -or $d -lt $loc.d) {$loc.d = $d}
        }
    }
}

foreach ($p in $data) {
    $p.a = area($p.d)
}

$smallestArea = $data | ? {$_.finite} | measure -minimum a | select -ExpandProperty Minimum

Write-Host ("Part 1 = {0} ({1})" -f $smallestArea,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

Write-Host ("Part 2 = {0} ({1})" -f "answer",(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan




