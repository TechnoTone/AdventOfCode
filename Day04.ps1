
#Part 1

$start = Get-Date

$guard = 0
$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day04.data) |
        % {
            [PSCustomObject]@{
                When = Get-Date ($_.Substring(1,16))
                What = $_.Substring(19)
            }
        } |
        sort When |
        % { $what = $_.What
            if ($what -match "Guard") {
                $guard = $what.Split(" ")[1].Substring(1)
                $what = "begins shift"
            }
            [PSCustomObject]@{
                When = $_.When
                Who = $guard
                What = $what
            }
        }

$guards = $data | group Who

foreach ($guard in $guards) {
    $events = $guard.Group | ? {$_ -notmatch "shift"} | group "what"
    $guard | Add-Member NoteProperty "Events" @()
    if ($events) {
        for ($n=0; $n -lt $events[0].Group.Count; $n++) {
            $guard.Events += ([PSCustomObject]@{
                Asleep = $events[0].Group[$n].When.Minute
                Awake = $events[1].Group[$n].When.Minute
                Duration = $events[1].Group[$n].When.Minute - $events[0].Group[$n].When.Minute
            })
        }
    }
    $guard | Add-Member NoteProperty "MinutesAsleep" ($guard.Events | measure -Sum Duration | select -ExpandProperty Sum)
}

$bestGuard = $guards | sort -Descending MinutesAsleep | select -First 1

$minutes = foreach ($minute in @(0..59)) {
    [PSCustomObject] @{
        Minute = $minute
        SleepCount = ($bestGuard.Events | ? {$_.Asleep -le $minute -and $_.Awake -gt $minute}).Count
    }
}

$bestMinute = $minutes | sort -Descending SleepCount | select -First 1

$answer1 = [int]::Parse($bestGuard.Name) * $bestMinute.Minute
Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

foreach ($guard in $guards) {
    $minutes = foreach ($minute in @(0..59)) {
        [PSCustomObject] @{
            Minute = $minute
            SleepCount = ($guard.Events | ? {$_.Asleep -le $minute -and $_.Awake -gt $minute}).Count
        }
    } 
    $minutes = $minutes | sort -Descending SleepCount 

    $guard | Add-Member "MostAsleepOn" ( $minutes[0].Minute)
    $guard | Add-Member "MostAsleepCount" ( $minutes[0].SleepCount)
}

$guards | sort -Descending MostAsleepCount | select -First 1 | % {

    $answer2 = [int]::Parse($_.Name) * $_.MostAsleepOn
    Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

}
