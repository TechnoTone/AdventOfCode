﻿
#Part 1

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day02.data)

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