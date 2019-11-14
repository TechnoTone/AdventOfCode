

if (!$device) {
    . .\Day16.ps1
}


function RunProgram($instructions, $ipRegister = 0, $maxSteps = 1) {

    $ip = 0
    $stepCount = 0

    while ($ip -lt $instructions.Count) {

        $instruction = $instructions[$ip]
        $device.R[$ipRegister] = $ip

        $log = "ip={0} [{1}] {2}" -f $ip, ($device.R -join ","), $instruction

        $i = $instruction -split " "
        $device.($i[0])([int]$i[1],[int]$i[2],[int]$i[3])

        $ip = $device.R[$ipRegister] + 1
        
        $log += " [{0}]" -f ($device.R -join ",")

        #if ($host.ui.RawUI.KeyAvailable) {
            Write-Host $log
            $host.UI.RawUI.ReadKey() | Out-Null
        #}

        if (++$stepCount -eq $maxSteps) { return $false }
    }

    return $true
}


#Part 1

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day21.data)
$startRegister = [int]::Parse($data[0][-1])
$data = $data | select -Skip 1
cls

$answer1 = $null
$start = Get-Date

$r1 = 0
$maxSteps = 1000

do {

    write-host $r1 $maxSteps

    $device.Init(@($r1,0,0,0,0,0))
    $complete = RunProgram $data -ipRegister $startRegister -maxSteps $maxSteps

    if (++$r1 -ge 10000) {
        $r1 = 0
        $maxSteps++
    }
    
} until ($complete) 

$answer1 = $device.R[0]

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

return



#Part 2

$device.Init(@(1,0,0,0,0,0))
$answer2 = $null
$start = Get-Date

RunProgram $data -ipRegister $startRegister

$answer1 = $device.R[0]

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
