
#Part 1

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day02.data)

$counts = @(0)*30

$regEx = [regex]((97..122 | %{[char]$_+"+"}) -join "|")


foreach ($line in $data) {
    $line = ($line.ToCharArray()|sort) -join ""
    $regEx.Matches($line) | ? {$_.Length -gt 1} | group Length | % {
        $counts[$_.Name] = $counts[$_.Name] + 1
    }
    #write-host ("{0} - {1}" -f $line,($counts -join ",")) -ForegroundColor Gray
}

$checksum = 1
$counts | % {
    if ($_ -gt 0) {
        $checksum *= $_
    }
}

Write-Host "Part 1 = $checksum" -ForegroundColor Cyan

#Part 2

for ($i = 0; $i -lt $data.Count; $i++) {
    $line = $data[$i]
    for ($n = 0; $n -lt $line.Length; $n++) {
        $line2 = $line.Remove($n,1).Insert($n,".")
        if (($data[$i..$data.Count] -match $line2).Count -gt 1) {
            Write-Host "Part 2 = "$line2.Replace(".","")
        }
    }
}

