

function parseData($data) {
    $result = [PSCustomObject] @{Before=$null;Inst=$null;After=$null}
    $data | % {
        $l = $_ -split ":"
        if ($l.Count -eq 1) {
            $result.Inst = $l -split " " | % {[int]$_}
        } else {
            $v = $l[1] -replace "[\[|\]| ]","" -split "," | % {[int]$_}
            if ($l[0] -eq "Before") {
                $result.Before = $v
            } else {
                $result.After = $v
                Write-Output $result
                $result = [PSCustomObject] @{Before=$null;Inst=$null;After=$null}
            }
        }
    }
}


$device = [PSCustomObject]@{
    R=@(0,0,0,0)
} | Add-Member -PassThru -MemberType ScriptMethod -Name "Init" -Value {
    param($r1,$r2,$r3,$r4)
    if ($r1 -is [Array]) {
        $this.R = $r1
    } else {
        $this.R = @($r1,$r2,$r3,$r4)
    }
} | Add-Member -PassThru -MemberType ScriptMethod -Name "Equals" -Force -Value {
    param($r1,$r2,$r3,$r4)
    if ($r1 -is [Array]) {
        ($this.R -join ",") -eq ($r1 -join ",")
    } else {
        ($this.R -join ",") -eq (@($r1,$r2,$r3,$r4) -join ",")
    }
}




#Examples

$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\day16.examples.txt) )

$data




return

#Part 1

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


