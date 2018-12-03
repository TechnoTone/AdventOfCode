
#Part 1

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day03.data)

$cloth = New-Object "int[,]" 1000,1000

$n=0
foreach ($line in $data) {
    $parts = $line.Replace(" ","").Split("@,x:") | % {try{[int]$_}catch{}}
    for ($x=$parts[1]; $x -lt $parts[1]+$parts[3]; $x++) {
        for ($y=$parts[2]; $y -lt $parts[2]+$parts[4]; $y++) {
            $cloth[$x,$y]=$cloth[$x,$y]+1
        }
    }
}

$overlaps = ($cloth | ? {$_ -gt 1}).Count

Write-Host "Part 1 = $overlaps" -ForegroundColor Cyan



#Part 2

foreach ($line in $data) {
    $parts = $line.Replace(" ","").Split("@,x:") | % {try{[int]$_}catch{}}
    $ok=$true
    for ($x=$parts[1]; $x -lt $parts[1]+$parts[3]; $x++) {
        for ($y=$parts[2]; $y -lt $parts[2]+$parts[4]; $y++) {
            if ($cloth[$x,$y] -gt 1) {
                $ok=$false
            }
        }
    }
    if ($ok) {
        Write-Host "Part 2 = $line" -ForegroundColor Cyan
        exit
    }
}
