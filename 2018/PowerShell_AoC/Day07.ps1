

$start = Get-Date

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day07.data)

function newPair ([string] $s) {
    [PSCustomObject] @{
        DoThis = $s[5]
        BeforeThis = $s[36]
    }
}

$pairs = $data | % {newPair $_}



#Part 1

$toDo = $pairs | sort DoThis
$answer1 = ""

while ($toDo.Count -gt 0) {
    $beforeThese = $toDo.BeforeThis | sort | select -Unique
    $next = $toDo.DoThis | sort | select -Unique | ? {$_ -notin $beforeThese} | select -First 1
    $answer1 += $next
    $toDo = $toDo | ? {$_.DoThis -notin $next}
}

Write-Host ("Part 1 = {0} ({1})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
#AEMNPOJWISZCDFUKBXQTHVLG


#Part 2

Write-Host ("Part 2 = {0} ({1})" -f "answer",(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


