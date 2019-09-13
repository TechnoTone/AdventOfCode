

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
                $result
                $result = [PSCustomObject] @{Before=$null;Inst=$null;After=$null}
            }
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "ToString" -Value {
        [PSCustomObject] @{
            Before = $this.Before -join ","
            Inst = $this.Inst -join ","
            After = $this.After -join ","
        }
    }
}


$device = [PSCustomObject]@{
    R = @(0,0,0,0)
    I = "addr,addi,bani,banr,bori,borr,eqir,eqri,eqrr,gtir,gtri,gtrr,muli,mulr,seti,setr" -split ","
    OpCodes = @{}
} | Add-Member -PassThru -MemberType ScriptMethod -Name "Init" -Value {
    param($r1,$r2,$r3,$r4)
    if ($r1 -is [Array]) {
        $this.R = $r1.Clone()
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
} | Add-Member -PassThru -MemberType ScriptMethod -Name "addr" -Value {
    #addr (add register) stores into register C the result of adding register A and register B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] + $this.R[$B]
} | Add-Member -PassThru -MemberType ScriptMethod -Name "addi" -Value {
    #addi (add immediate) stores into register C the result of adding register A and value B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] + $B
} | Add-Member -PassThru -MemberType ScriptMethod -Name "mulr" -Value {
    #mulr (multiply register) stores into register C the result of multiplying register A and register B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] * $this.R[$B]
} | Add-Member -PassThru -MemberType ScriptMethod -Name "muli" -Value {
    #muli (multiply immediate) stores into register C the result of multiplying register A and value B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] * $B
} | Add-Member -PassThru -MemberType ScriptMethod -Name "banr" -Value {
    #banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] -band $this.R[$B]
} | Add-Member -PassThru -MemberType ScriptMethod -Name "bani" -Value {
    #bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] -band $B
} | Add-Member -PassThru -MemberType ScriptMethod -Name "borr" -Value {
    #borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] -bor $this.R[$B]
} | Add-Member -PassThru -MemberType ScriptMethod -Name "bori" -Value {
    #bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A] -bor $B
} | Add-Member -PassThru -MemberType ScriptMethod -Name "setr" -Value {
    #setr (set register) copies the contents of register A into register C. (Input B is ignored.)
    param ($A,$B,$C)
    $this.R[$C] = $this.R[$A]
} | Add-Member -PassThru -MemberType ScriptMethod -Name "seti" -Value {
    #seti (set immediate) stores value A into register C. (Input B is ignored.)
    param ($A,$B,$C)
    $this.R[$C] = $A
} | Add-Member -PassThru -MemberType ScriptMethod -Name "gtir" -Value {
    #gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B. Otherwise, register C is set to 0.
    param ($A,$B,$C)
    $this.R[$C] = [int]($A -gt $this.R[$B])
} | Add-Member -PassThru -MemberType ScriptMethod -Name "gtri" -Value {
    #gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B. Otherwise, register C is set to 0.
    param ($A,$B,$C)
    $this.R[$C] = [int]($this.R[$A] -gt $B)
} | Add-Member -PassThru -MemberType ScriptMethod -Name "gtrr" -Value {
    #gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B. Otherwise, register C is set to 0.
    param ($A,$B,$C)
    $this.R[$C] = [int]($this.R[$A] -gt $this.R[$B])
} | Add-Member -PassThru -MemberType ScriptMethod -Name "eqir" -Value {
    #eqir (equal immediate/register) sets register C to 1 if value A is equal to register B. Otherwise, register C is set to 0.
    param ($A,$B,$C)
    $this.R[$C] = [int]($A -eq $this.R[$B])
} | Add-Member -PassThru -MemberType ScriptMethod -Name "eqri" -Value {
    #eqri (equal register/immediate) sets register C to 1 if register A is equal to value B. Otherwise, register C is set to 0.
    param ($A,$B,$C)
    $this.R[$C] = [int]($this.R[$A] -eq $B)
} | Add-Member -PassThru -MemberType ScriptMethod -Name "eqrr" -Value {
    #eqrr (equal register/register) sets register C to 1 if register A is equal to register B. Otherwise, register C is set to 0.
    param ($A,$B,$C)
    $this.R[$C] = [int]($this.R[$A] -eq $this.R[$B])
} | Add-Member -PassThru -MemberType ScriptMethod -Name "RunProgram" -Value {
    param ($data)
    foreach ($d in $data) {
        $op = $this.OpCodes[$d.I]
        $this.$op($d.A,$d.B,$d.C)
    }
}


function testDevice ($test) {
    $A = $test.Inst[1]
    $B = $test.Inst[2]
    $C = $test.Inst[3]
    
    #Write-Host $test

    foreach ($I in $device.I) {
        #Write-Host $test.Before -ForegroundColor Gray
        $device.Init($test.Before)
        $device.$I($A,$B,$C)
        if ($device.Equals($test.After)) {
            $I
            #Write-Host "$I "($device.R -join ",") -ForegroundColor Green
        #} else {
           # Write-Host "$I "($device.R -join ",") -ForegroundColor Red
        }
    }
#    pause
}

#Examples

cls


#Part 1

$start = Get-Date

$answer1 = 0

$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day16.samples) )
$data | % {

    $instructions = testDevice $_
    #Write-Host $_ ($instructions -join ",")
    if ($instructions.Count -ge 3) {
        $answer1++
    }

}

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$results = $data | % {[PSCustomObject]@{Inst=$_.Inst[0];Ops=(testDevice $_)}} | sort Inst -Unique

$ops = $device.I
$opcodes = @{}


while ($ops) {

    foreach ($op in (($results | ? {$_.ops.count -eq 1}).ops | select -Unique)) {
        $n = ($results | ? {$_.ops.count -eq 1 -and $_.ops -eq $op}) | % {$_.Inst} | select -Unique
        if ($n.Count -gt 1) {
            Write-Host "ERROR!" -ForegroundColor Red
            return
        } else {
            $opCodes[$n] = $op
            $results | % {$_.ops = $_.ops | ? {$_ -ne $op}}
            $ops = $ops | ? {$_ -ne $op}
        }
    }
}

$device.OpCodes = $opCodes
$device.Init(0,0,0,0)

return # only need the device now for day 19


$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day16.data) | 
            % {$d = $_ -split " "; [PSCustomObject]@{I=[int]$d[0];A=[int]$d[1];B=[int]$d[2];C=[int]$d[3]}}

$device.RunProgram($data)

$answer2 = $device.R[0]

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
