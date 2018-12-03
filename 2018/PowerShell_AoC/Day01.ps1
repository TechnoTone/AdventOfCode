
$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day01.data) |
        % {[int]::Parse($_)}



#Part 1

$total = $data | measure -Sum | select -ExpandProperty Sum

Write-Host "Part 1 = $total" -ForegroundColor Cyan



#Part 2

$total = 0
$totals = @{}
do {
    $data | % {
        $total += $_
        if ($totals[$total]) {
            Write-Host "Part 2 = $total" -ForegroundColor Cyan
            break
        }
        $totals[$total] = 1
    }
} while ($true)
