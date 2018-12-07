

$start = Get-Date

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day07.data)

function newPair ([string] $s) {
    [PSCustomObject] @{
        DoThis = $s[5]
        BeforeThis = $s[36]
     }
 }

$pairs = $data | % {newPair $_}

$steps = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() | % {
#$steps = 'ABCDEF'.ToCharArray() | % {
    $step = $_
    [PSCustomObject]@{
        Step = $step
        Time = $_.ToByte($null)-4
        PreReqs = ($pairs | ? {$_.BeforeThis -eq $step} | select -ExpandProperty DoThis -Unique | sort)
        Worker = $null
    }
}


#Part 1

$toDo = $steps
$answer1 = ""

while ($toDo) {
    $next = $ToDo | ? {-not ($_.PreReqs | ? {$_ -in $ToDo.Step})} | select -First 1
    $answer1 += $next.Step
    $toDo = $toDo | ? {$_ -ne $next}
}

Write-Host ("Part 1 = {0} ({1})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
#AEMNPOJWISZCDFUKBXQTHVLGRY


#Part 2

$toDo = $steps
$answer2 = ""
$T = 0

function newWorker([int]$id){
    $w = [PSCustomObject]@{
        Id = $_
        CurrentStep = ""
        StartedAt = 0
        FinishAt = 0
    }
    $w | Add-Member ScriptProperty IsAvailable {!$this.CurrentStep}
    $w | Add-Member ScriptProperty IsBusy {!!$this.CurrentStep}
    $w | Add-Member ScriptProperty TimeRemaining {if ($this.IsAvailble -or $this.FinishAt -lt $T) {0} else {$this.FinishAt - $T}}
    $w | Add-Member ScriptMethod AssignTo {
        param($step) 
        if (!($this.IsAvailable)) {
            throw "Worker is busy"
        } else {
            $step.Worker = $this
            $this.CurrentStep = $step.Step
            $this.StartedAt = $T
            $this.FinishAt = $T + $step.Time
        }
    }
    $w | Add-Member ScriptMethod Finished {
        $this.CurrentStep = $null
        $this.StartedAt = 0
        $this.FinishAt = 0
    }
    return $w
}

$workers = 1..5 | % {newWorker $_}

function availableWorker () {
    $script:workers | ? {$_.IsAvailable} | select -First 1
}

function doWork () {
    $busyWorkers = $script:workers | ? {$_.IsBusy}
    $timeWarp = $busyWorkers | select -ExpandProperty TimeRemaining | sort | select -First 1
    if ($timeWarp) { $script:T += $timeWarp }
    $busyWorkers | ? {$_.TimeRemaining -le 0} | % {
        $bw = $_
        $script:toDo = $script:toDo | ? {$_.Step -ne $bw.CurrentStep}
        $bw.Finished()
    }
}

while ($toDo) {
#    cls
#    write-host $T
#    $toDo | ft
#    $workers | ft

    $next = $ToDo | ? {!$_.Worker -and !($_.PreReqs | ? {$_ -in $ToDo.Step})} | select -First 1
    if ($next) {
        $worker = availableWorker
        if ($worker) {
            $worker.AssignTo($next)
        } else {
            doWork
        }
    } else {
        doWork
    }
}

$answer2 = $T

Write-Host ("Part 2 = {0} ({1})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
