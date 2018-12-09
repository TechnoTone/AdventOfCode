
$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day03.data)


#Part 1

$start = Get-Date

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

$answer1 = ($cloth | ? {$_ -gt 1}).Count

Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

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
        $answer2 = $line
        Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
        exit
    }
}
