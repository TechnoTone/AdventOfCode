
$data = Import-Csv (Join-Path ($PSCommandPath | Split-Path -Parent) Day09.data)
        
function padLeft($what, $padding, $length) {
    (($padding*$length)+$what).Substring($what.ToString().Length)
}

function showCircle ($player, $circle, $current) {
    $line = "[{0}] " -f (padLeft $player " " 3)
    $line += ($circle -join " ").Replace((" {0} " -f $current.Value), ("({0})" -f $current.Value))
    #$line.Replace("  "," ") | Out-File -FilePath C:\Users\Techn_000\Desktop\Day09_Test2_output.txt -Append
    $line.Replace("  "," ") | Out-Host
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

    $showCircle = $false

    $players = [int]$row.Players
    $scores = New-Object "long[]" ($players+1)

    $next = 0
    $circle = New-Object Collections.Generic.LinkedList[Int]
    $current = $circle.First

    $circle.Add(0)
    $current = $circle.First

    if ($showCircle) {
        showCircle -1 $circle $current
    }
    
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

        if ($showCircle) {
            showCircle $player $circle $current
        }
    }
    
    $highestPlayer = 0
    $highestScore = 0
    for ($p=1; $p -le $scores.Count-1; $p++) {
        if ($highestScore -lt $scores[$p]) {
            $highestPlayer = $p
            $highestScore = $scores[$p]
        }
    }
    return $highestScore

}



#Examples

Write-Host
"Players  LastMarble  ExpectedHighScore  HighestScore" | Write-Host -ForegroundColor DarkGray
"----------------------------------------------------" | Write-Host -ForegroundColor DarkGray

foreach ($row in $data[0..5]) {

    $row.HighestScore = play $row

    $line = (padLeft $row.Players " " 7) +
            (padLeft $row.LastMarble " " 12) +
            (padLeft $row.ExpectedHighScore " " 19) +
            (padLeft $row.HighestScore " " 14)
    
    if ($row.ExpectedHighScore -eq $row.HighestScore) {
        $line | Write-Host -ForegroundColor Green
    } else {
        $line | Write-Host -ForegroundColor Red
    }
}

return


#Part 1

$start = Get-Date

$row = $data[6]
$row.HighestScore = play $row
$answer1 = $row.HighestScore

Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$start = Get-Date

$row = $data[7]
$row.HighestScore = play $row
$answer2 = $row.HighestScore

Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

$data
