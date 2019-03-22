


function parseData($data) {

    #find minimum/maximum x and y
    #create grid array of appropriate size
    #load grid with $data
    
    $grid = New-Object "int[,]" $dX,$dY
    
    $result = [PSCustomObject] @{Grid}
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






$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day17.test) )



$data

return
#Examples




#Part 1

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


