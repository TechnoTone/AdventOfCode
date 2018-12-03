
#Part 1

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day01.data)

$total = 0

$data | % {
    $total += [int]::Parse($_)
}

Write-Host "Part 1 = $total" -ForegroundColor Cyan



#Part 2

$total = 0
$totals = @()
do {
    $data | % {
        $total += [int]::Parse($_)
        if ($totals.IndexOf($total) -ge 0) {
            Write-Host "Part 2 = $total" -ForegroundColor Cyan
            break
        }
        $totals = $totals + $total
    }
} until ($false)
