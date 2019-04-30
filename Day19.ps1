

if (!$device) {
    . .\Day16.ps1
}

$device.R = @(0,0,0,0,0,0)


#Examples

$instructions = "seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5" | Split-String -NewLine




#Part 1

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day19.data)
cls
$data

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


