
$examples = Import-Csv (Join-Path ($PSCommandPath | Split-Path -Parent) Day11.data)


function toInt([parameter(ValueFromPipeline=$true)]$data) {
    $data.X = [int]$data.X
    $data.Y = [int]$data.Y
    $data.SerialNo = [int]$data.SerialNo
    $data.Power = [int]$data.Power
    $data
}

function getPower($SerialNo,$X,$Y){
    $rackId = ($X + 10)
    $power = ($rackId * $Y + $SerialNo) * $rackId
    [Math]::Truncate($power / 100) % 10 - 5
}

function getGrid($serialNo) {
    $grid = New-Object "int[,]" 301,301

    for ($x = 1; $x -le 300; $x++) {
        for ($y = 1; $y -le 300; $y++) {
            $grid[$x,$y] = getPower $serialNo $x $y
        }
    }
    Write-Output -NoEnumerate $grid
}

function pad($n) {
    if ($n -lt 0) {
        ""+$n
    } else {
        " "+$n
    }
}

function GridToCSV($grid,$X1,$Y1,$X2,$Y2) {
    write-host "ShowGrid: $X1,$Y1 - $X2,$Y2"
    for ($Y = $Y1; $Y -le $Y2; $Y++) {
        $values = @()
        for ($X = $X1; $X -le $X2; $X++) {
            $values = $values + ($grid[$X,$Y])
        }
        ($values -join ",")
        #"`n" | out-file -Append -FilePath "grid.csv"
    }
}

function showGrid($grid,$X1,$Y1,$X2,$Y2) {
    write-host "ShowGrid: $X1,$Y1 - $X2,$Y2"
    for ($Y = $Y1; $Y -le $Y2; $Y++) {
        for ($X = $X1; $X -le $X2; $X++) {
            Write-Host ((pad $grid[$X,$Y])+"  ") -NoNewline
        }
        Write-Host
    }
}

function show5by5Grid($grid,$X,$Y) {
    showGrid $grid, $X $Y ($X+4) ($Y+4)
}

function getSummedAreaTable ($grid) {
    $SAT = New-Object "int[,]" 302,302

    $SAT[1,1] = $grid[1,1]

    for ($X=2; $X -le 300; $X++) {
        $SAT[$X,1] = $SAT[($X-1), 1] + $grid[$X,1]
    }

    for ($Y=2; $Y -le 300; $Y++) {
        $SAT[1,$Y] = $SAT[1, ($Y-1)] + $grid[1,$Y]
    }

    for ($Y=2; $Y -le 300; $Y++) {
        for ($X=2; $X -le 300; $X++) {
            $SAT[$X,$Y] = $SAT[($X-1),$Y] + $SAT[$X, ($Y-1)] - $SAT[($X-1), ($Y-1)] + $grid[$X,$Y]
        }
    }
    Write-Output -NoEnumerate $SAT
}

function getSATTotal($SAT,$X,$Y,$P) {
    $SAT[($X+$P-1),($Y+$P-1)] - 
    $SAT[($X+$P-1), ($Y-1)] - 
    $SAT[($X-1), ($Y+$P-1)] + 
    $SAT[($X-1), ($Y-1)]
}

function getTotal2($grid,$X,$Y,$P) {
    $t = 0
    for ($y1 = $Y; $y1 -lt $Y+$P; $y1++) {
        for ($x1 = $X; $x1 -lt $X+$P; $x1++) {
            $t+=$grid[$x1,$y1]
        }
    }
    $t
}

function getTotal($grid,$X,$Y) {
    getTotal2 $grid $X $Y 3
}

function getBestSAT($SAT,$power){
    $bestTotal = @{
        Total=-999
        X=0
        Y=0
    }
    
    for ($Y=1; $Y -lt (302-$power); $Y++) {
        for ($X=1; $X -lt (302-$power); $X++) {
            $t = getSATTotal $SAT $X $Y $Power
            if ($t -gt $bestTotal.Total) {
                $bestTotal.Total = $t
                $bestTotal.X = $X
                $bestTotal.Y = $Y
            }
        }
    }

    $bestTotal
}


#Examples

#$examples | % {
#    $data = $_ | toInt
#        write-host (getPower $data.SerialNo $data.X $data.Y)
#}

#$grid = getGrid 18
#show5by5Grid $grid 32 44
#$SAT = getSummedAreaTable $grid
#show5by5Grid $SAT 32 44

#write-host ("Total2: " + (getTotal2 $grid 33 45 3))
#write-host ("Total3: " + (getSATTotal $SAT 33 45 3))

#Write-Host

#$grid = getGrid 42
#show5by5Grid $grid 20 60
#write-host ("Total: " + (getTotal $grid 21 61))


#Part 1

$start = Get-Date

$grid = getGrid 9810
$SAT = getSummedAreaTable $grid
getBestSAT $SAT 3 | Out-Host

Write-Host ("Part 1 = {0:0.0000}" -f (Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$start = Get-Date

$bestTotal = @{
    Total=0
    X=0
    Y=0
    Power=0
}

for ($power=3; $power -le 300; $power++) {
    $t = getBestSAT $SAT $power
    write-host $power $t.Total
    if ($t.Total -gt $bestTotal.Total) {
        $bestTotal.Total = $t.Total
        $bestTotal.X = $t.X
        $bestTotal.Y = $t.Y
        $bestTotal.Power = $t.Power
    }
}

# This loop still takes far too long.
# Manually stopped it at 25 when I saw that 16 was a peek in the total.

Write-Host $bestTotal
Write-Host ("Part 2 = {0:0.0000}" -f (Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

