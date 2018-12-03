
$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day01.data)



#Part 1

$total = 0

$data | % {
    $total += [int]::Parse($_)
}

Write-Host "Part 1 = $total" -ForegroundColor Cyan



#Part 2

$total = 0
$totals = @{}
do {
    $data | % {
        $total += [int]::Parse($_)
        if ($totals[$total]) {
            Write-Host "Part 2 = $total" -ForegroundColor Cyan
            break
        }
        $totals[$total] = 1
    }
} while ($true)
