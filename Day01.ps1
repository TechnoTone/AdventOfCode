
$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day01.data) |
        % {[int]::Parse($_)}



#Part 1

$start = Get-Date

$answer1 = $data | measure -Sum | select -ExpandProperty Sum

Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$answer2 = 0
$totals = @{}

do {
    $data | % {
        $total += $_
        if ($totals[$total]) {
            Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
            break
        }
        $totals[$total] = 1
    }
} while ($true)
