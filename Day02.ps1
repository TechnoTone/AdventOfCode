
$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day02.data)


#Part 1

$start = Get-Date

$regEx = [regex]((97..122 | %{[char]$_+"+"}) -join "|")

$twos = 0
$threes = 0

foreach ($line in $data) {
    $line = ($line.ToCharArray()|sort) -join ""
    $groupings = $regEx.Matches($line).Length 
    if ($groupings -contains 2) { 
        $twos ++ }
    if ($groupings -contains 3) { 
        $threes ++ }
}

$answer1 = $twos * $threes


Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

#Part 2

$start = Get-Date

for ($i = 0; $i -lt $data.Count; $i++) {
    $line = $data[$i]
    for ($n = 0; $n -lt $line.Length; $n++) {
        $line2 = $line.Remove($n,1).Insert($n,".")
        if (($data[$i..$data.Count] -match $line2).Count -gt 1) {
            $answer2 = $line2.Replace(".","")
            Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
            return
        }
    }
}
