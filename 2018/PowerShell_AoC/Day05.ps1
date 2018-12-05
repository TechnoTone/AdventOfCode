
$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day05.data)

$regEx = [regex]((65..90 | %{[char]$_+[char]($_+32)+"|"+[char]($_+32)+[char]$_}) -join "|")

#Part 1
while ($data -and $regEx.IsMatch($data)) {
    $data = $regEx.Replace($data, "")
}

Write-Host ("Part 1 = {0}" -f $data.Length) -ForegroundColor Cyan



#Part 2

$results = @()
foreach ($n in @(65..90)) {
    $regEx2 = [regex]([char]$n+"|"+[char]($n+32))
    $data2 = $regEx2.Replace($data, "")
    while ($data2 -and $regEx.IsMatch($data2)) {
        $data2 = $regEx.Replace($data2, "")
    }
    $results = $results + $data2.Length
}

$results

Write-Host ("Part 2 = {0}" -f ($results | measure -Minimum).Minimum) -ForegroundColor Cyan
