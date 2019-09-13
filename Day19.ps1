

if (!$device) {
    . .\Day16.ps1
}

$device.Init(@(0,0,0,0,0,0))



function RunProgram($instructions, $ipRegister = 0) {

    $ip = 0

    while ($ip -lt $instructions.Count) {

        $instruction = $instructions[$ip]
        $device.R[$ipRegister] = $ip

        $log = "ip={0} [{1}] {2}" -f $ip, ($device.R -join ","), $instruction

        $i = $instruction -split " "
        $device.($i[0])([int]$i[1],[int]$i[2],[int]$i[3])

        $ip = $device.R[$ipRegister] + 1


        $log += " [{0}]" -f ($device.R -join ",")

        #if ($host.ui.RawUI.KeyAvailable) {
            #Write-Host $log
            #$host.UI.RawUI.ReadKey() | Out-Null
        #}
    }

}


cls

#Examples

#$instructions = "seti 5 0 1
#                 seti 6 0 2
#                 addi 0 1 0
#                 addr 1 2 3
#                 setr 1 0 0
#                 seti 8 0 4
#                 seti 9 0 5" | Split-String -NewLine | % {$_.Trim()}

#RunProgram $instructions
#return





#Part 1

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day19.data)
$startRegister = [int]::Parse($data[0][-1])
$data = $data | select -Skip 1
cls

$start = Get-Date

RunProgram $data -ipRegister $startRegister

$answer1 = $data.R[0]

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

return



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
