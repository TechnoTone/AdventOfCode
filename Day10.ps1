
function parse ($line) {
    $line | % {$d=$_.Replace(" ","").Split("<,>");[PSCustomObject]@{
        PX=[int]$d[1]
        PY=[int]$d[2]
        VX=[int]$d[4]
        VY=[int]$d[5]
    }}
}

function update ([parameter(ValueFromPipeline=$true)]$star) {
    $star.PX += $star.VX
    $star.PY += $star.VY
}

function draw ($stars) {
    $sorted = $stars | sort -Property @{Expression = "PY"; Ascending = $true},@{Expression = "PX"; Ascending = $true}
    $minX = ($stars | measure -Minimum PX).Minimum
    $minY = ($stars | measure -Minimum PY).Minimum
    $l=$minY
    $sorted | group PY | % {
        while ($l -lt $_.Group[0].PY) {
            $l++
            Write-Host ""
        }
        $line = ""
        $_.Group | % {
            $line += (" "*($_.PX-$minX-$line.Length-1))+"*"
        }
        Write-Host $line
    }
}

#Examples

$example = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day10test.data) | % {parse $_}
$example

do {

    $star | update
    draw $example

} while ($true)


$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day10.data) | % {parse $_}
$data

#Part 1

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


