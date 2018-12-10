
function parse ($line) {
    $line | % {$d=$_.Replace(" ","").Split("<,>"); newStar $d[1] $d[2] $d[4] $d[5]}
}

function newStar ($PX, $PY, $VX, $VY) {
    [PSCustomObject]@{
        PX=[int]$PX
        PY=[int]$PY
        VX=[int]$VX
        VY=[int]$VY
    }
}

function moveStar ($star, $time) {
    newStar ($star.PX+($star.VX*$time)) ($star.PY+($star.VY*$time)) $star.VX $star.VY
}

function moveStars($stars, $time) {
    $stars | % {moveStar $_ $time}
}

function sizeOf ($stars) {
    $minX = ($stars | measure -Minimum PX).Minimum
    $maxX = ($stars | measure -Maximum PX).Maximum
    $minY = ($stars | measure -Minimum PY).Minimum
    $maxY = ($stars | measure -Maximum PY).Maximum
    $maxX + $maxY - $minX - $minY
}

function draw ($stars) {
    $sorted = $stars | sort -Property @{Expression = "PY"; Ascending = $true},@{Expression = "PX"; Ascending = $true}
    $minX = ($stars | measure -Minimum PX).Minimum
    $maxX = ($stars | measure -Maximum PX).Maximum
    $minY = ($stars | measure -Minimum PY).Minimum
    $l=$minY
    $sorted | group PY | % {
        while ($l -lt $_.Group[0].PY) {
            $l++
        }
        $line = @(" ") * ($maxX - $minX + 1)
        $_.Group | % {
            $line[($_.PX-$minX)] = "*"
        }
        Write-Host ($line -join "")
        $l++
    }
}



#Example

cls

$stars = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day10test.data) | % {parse $_}
$time = 0

$smallest = sizeOf $stars
$RateOfChange = $smallest - (sizeof ( moveStars $stars 1))

Write-Host "T: 0.  Size: $smallest.  ApproxRateOfChange: $RateOfChange"

do {
    $dT = [int]($smallest / 2 / $RateOfChange) - 1
    if ($dT -lt 1) {$dT = 1}
    $time += $dT

    if ($smallest -gt 10000) {
        $time += 5000
    } elseif ($smallest -gt 1000) {
        $time += 500
    } elseif ($smallest -gt 100) {
        $time += 50
    } else {
        $time += 1
    }
    $newStars = moveStars $stars $time
    $size = sizeOf $newStars

    Write-Host "T: $time.  Size: $size."

    if ($size -lt $smallest) {
        $smallest = $size
    } else {
        $time--
        break
    }

} while ($true)

draw (moveStars $stars $time)
Write-Host "`nTime: $time seconds"

#return

#Part 1 & 2

$start = Get-Date

$stars = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day10.data) | % {parse $_}
$time = 0

$smallest = sizeOf $stars
$RateOfChange = $smallest - (sizeof ( moveStars $stars 1))

Write-Host "T: 0.  Size: $smallest.  ApproxRateOfChange: $RateOfChange"

do {
    $dT = [int]($smallest / 2 / $RateOfChange) - 1
    if ($dT -lt 1) {$dT = 1}
    $time += $dT

    $newStars = moveStars $stars $time
    $size = sizeOf $newStars

    Write-Host "T: $time.  Size: $size."

    if ($size -lt $smallest) {
        $smallest = $size
    } else {
        $time--
        break
    }

} while ($true)

draw (moveStars $stars $time)
Write-Host "`nTime: $time seconds"
Write-Host ("Parts 1 & 2 {0:0.0000}" -f (Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
