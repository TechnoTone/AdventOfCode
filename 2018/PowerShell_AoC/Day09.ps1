
$start = Get-Date

$data = Import-Csv (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day09.data)

<<<<<<< HEAD
function padLeft($what, $padding, $length) {
    (($padding*$length)+$what).Substring($what.ToString().Length)
}

function showCircle ($player, $circle, $current) {
    $line = "[{0}] " -f (padLeft $player " " 3)
    $line += ($circle -join " ").Replace((" {0} " -f $current.Value), ("({0})" -f $current.Value))
    #$line.Replace("  "," ") | Out-File -FilePath C:\Users\Techn_000\Desktop\Day09_Test2_output.txt -Append
    $line.Replace("  "," ") | Out-Host
=======
function showCircle ($player, $circle, $current) {
    Write-Host ("[{0:000}] " -f $player) -NoNewline
    $circle.ForEach({
        if ($_ -eq $current.Value) {
            Write-Host (" {0} " -f $_) -ForegroundColor Yellow -NoNewline
        } else {
            Write-Host (" {0} " -f $_) -NoNewline
        }
    })
    Write-Host ""
>>>>>>> ea11fe9a8b8666062a5f35d2d6026b40c74bfc77
}

function getNext($circle, $node, $count = 1) {
    while ($count -gt 0) {
        $node = $node.Next
        if (!$node) {$node = $circle.First}
        $count--
    }
    $node
}

function getPrev($circle, $node, $count = 1) {
    while ($count -gt 0) {
        $node = $node.Previous
        if (!$node) {$node = $circle.Last}
        $count--
    }
    $node
}

function play ($row) {

    $players = [int]$row.Players
    $scores = New-Object "long[]" ($players+1)

    $next = 0
    $circle = New-Object Collections.Generic.LinkedList[Int]
    $current = $circle.First

    $circle.Add(0)
    $current = $circle.First

    #showCircle -1 $circle $current
    
    while ($next -lt $row.LastMarble) {
        $next++
        $player = ($next-1) % $players + 1

        if ($next % 23 -eq 0) {
            $current = getPrev $circle $current 6
            $scores[$player] += $next + (getPrev $circle $current).Value
            $circle.Remove((getPrev $circle $current))
        } else {
            $current = getNext $circle $current
            $current = $circle.AddAfter($current, $next)
        }

        #showCircle $player $circle $current
    }
    
    #write-host ""
    $highestPlayer = 0
    $highestScore = 0
    for ($p=1; $p -le $scores.Count-1; $p++) {
        #Write-Host ("{0}: {1}" -f $p,$scores[$p]) -ForegroundColor Green
        if ($highestScore -lt $scores[$p]) {
            $highestPlayer = $p
            $highestScore = $scores[$p]
        }
    }
    #Write-Host
    return $highestScore

}


foreach ($row in $data[0..5]) {
    $row.HighestScore = play $row
}

<<<<<<< HEAD

$data
return

=======
>>>>>>> ea11fe9a8b8666062a5f35d2d6026b40c74bfc77
#Part 1

$row = $data[6]
$row.HighestScore = play $row
$answer1 = $row.HighestScore

Write-Host ("Part 1 = {0} ({1})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$row = $data[7]
$row.HighestScore = play $row
$answer2 = $row.HighestScore

Write-Host ("Part 2 = {0} ({1})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

$data
