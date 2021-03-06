
function nObj($t,$x,$y) {
    [PSCustomObject]@{t=$t;x=$x;y=$y;h=200;LastPath=$null;LastMapState=$null
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "GetLocation" -Value {
        nLoc $this.x $this.y
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "SetLocation" -Value {
        param ($x,$y)
        $this.x = $x
        $this.y = $y
    }
}

function nLoc($x,$y){
    [PSCustomObject]@{x=$x;y=$y}
}

function abs ([int16] $i) {[Math]::Abs($i)}

function updateMap ($map,$x,$y,$value) {
    $map[$y] = $map[$y].Remove($x,1).Insert($x,$value)
}

function parseData ($data) {
    if (!$data[-1].StartsWith("#")){
        $target = [int]$data[-1]
        $data = $data[0..($data.Count-2)]
    } else {
        $target = -1
    }
    $map = $data
    $width = $map[0].Length
    $height = $map.Count
    $objects = New-Object System.Collections.ArrayList
    
    $map | Add-Member -MemberType ScriptMethod -Name "Update" -Value {
        param ($x,$y,$t)
    }

    for ($y=0; $y -lt $height; $y++) {
        for ($x=0; $x -lt $width; $x++) {
            $t = $data[$y][$x]
            if ($t -ne ".") {
                $objects.Add((nObj $t $x $y)) | Out-Null
            }
        }
    }

    $objects = $objects | sort y,x
    $types = $objects | select -Unique t
    
    [PSCustomObject]@{
        Target = $target
        Map = $map
        Width = $width
        Height = $height
        Objects = $objects
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "MoveEntity" -Value {
        param ($entity,$x,$y)
        updateMap $this.Map ($entity.x) ($entity.y) "."
        $entity.setLocation($x,$y)
        updateMap $this.Map ($entity.x) ($entity.y) ($entity.t)
    } | Add-Member -PassThru -MemberType ScriptProperty -Name "ObjectTypes" -Value {
        $this.Objects | select -Unique t
    } | Add-Member -PassThru -MemberType ScriptProperty -Name "GameOver" -Value {
        ($this.Objects | ? {$_.h} | select -Unique t).Count -le 2
    } | Add-Member -PassThru -MemberType ScriptProperty -Name "ObjectCounts" -Value {
        $this.Objects | group t -NoElement
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "Entities" -Value {
        $this.Objects | ? {$_.t -ne "#"} | sort y,x
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "GetEnemies" -Value {
        param ($entity)
        $this.Entities() | ? {$_.t -ne $entity.t -and $_.h -gt 0}
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "GetEnemyNeighbour" -Value {
        param ($entity)
        $this.GetEnemies($entity) | ? {
            ($_.x -eq $entity.x -and ((abs ($_.y-$entity.y)) -le 1)) -or
            ($_.y -eq $entity.y -and ((abs ($_.x-$entity.x)) -le 1))
        } | sort h,y,x | select -First 1
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "HasEnemyNeighbour" -Value {
        param ($entity)
        [bool]($this.GetEnemyNeighbour($entity))
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "BringOutYourDead" -Value {
#        $this.Objects | ? {$_.h -le 0} | % {
#            updateMap $this.Map $_.x $_.y "."
#        }
        $this.Objects = $this.Objects | ? {$_.h -gt 0}
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "ShortestPathToEnemy" -Value {
        param ($entity)
        $t = $entity.t.ToString().ToLower()
        $map = $this.Map.Clone()
        $queue = New-Object System.Collections.Queue
        $queue.Enqueue(@($entity.GetLocation()))
        $results = New-Object System.Collections.ArrayList
        while ($queue.Count) {
            $path = $queue.Dequeue()
            if ($results.Count -eq 0 -or $path.Length -le $results[0].Length ) {
                $x = $path[-1].x
                $y = $path[-1].y
                if ($this.HasEnemyNeighbour((nObj $t $x $y))) {
                    if ($results[0].Length -gt $path.Length) {
                        $results.Clear()
                    }
                    $results.Add($path) | Out-Null
                } else {
                    if ($map[$y-1][$x] -eq ".") {
                        updateMap $map $x ($y-1) $t
                        $queue.Enqueue($path+(nLoc $x ($y-1)))
                    }
                    if ($map[$y][$x-1] -eq ".") {
                        updateMap $map ($x-1) $y $t
                        $queue.Enqueue($path+(nLoc ($x-1) $y))
                    }
                    if ($map[$y][$x+1] -eq ".") {
                        updateMap $map ($x+1) $y $t
                        $queue.Enqueue($path+(nLoc ($x+1) $y))
                    }
                    if ($map[$y+1][$x] -eq ".") {
                        updateMap $map $x ($y+1) $t
                        $queue.Enqueue($path+(nLoc $x ($y+1)))
                    }
                }
            }
        }
        if ($results.Count) {
            $results | ? {$_[-1] -eq ($results | % {$_ | select -Last 1} | sort y,x | select -First 1)}
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "DrawState" -Value {
        foreach ($y in @(0..($this.Map.Count-1))) {
            Write-Host $this.Map[$y] "  " -NoNewline
            write-host (($this.Entities() | ? {$_.y -eq $y} | % {"{0}({1})" -f $_.t,$_.h}) -join ", ")
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "Run" -Value {
        param ($attack = 3)
        $round = 0
        while (!$this.GameOver) {
            $entities = $this.Entities()
            cls
            #$entities | sort t,h,y,x | oh
            $this.Map | oh
            Write-Host "$attack/$round"
            foreach ($entity in $entities) {
                if ($entity.h) {
                    Write-Host $entity.t -NoNewline
                    if ($this.GameOver) {
                        $this.BringOutYourDead()
                        return $round
                    }
                    if (!($this.HasEnemyNeighbour($entity))) {
                        if ($entity.LastMapState -eq ($data.Map -join "")) {
                            $path = $null
                        } else {
                            $path = $this.ShortestPathToEnemy($entity)
                            $entity.LastPath = $path
                            $entity.LastMapState = ($data.Map -join "")
                        }
                        if ($path) {
                            #Write-Host $entity,"Move",$path.Count
                            $this.MoveEntity($entity,$path[1].x,$path[1].y)
                        } else {
                            #Write-Host $entity,"Wait"
                        }
                    }
                    if ($this.HasEnemyNeighbour($entity)) {
                        $t = $entity.t
                        if ($t -eq "E") {
                            $a = $attack
                        } else {
                            $a = 3
                        }
                        $target = $this.GetEnemyNeighbour($entity)
                        #Write-Host $entity,"Fight",$target
                        if ($target.h -le $a) {
                            if ($t -eq "G" -and $attack -gt 3) {return}
                            $target.h=0
                            updateMap $this.Map $target.x $target.y "."
                            $this.BringOutYourDead()
                        } else {
                            $target.h = $target.h - $a
                        }
                    }
                }
            }
            #return
            $round++
            #Write-Host "After round $round" -ForegroundColor Magenta
            #$this.DrawState()
            #if ($round -ge 37) { 
            #    pause
            #}
        }
        return $round
    }
}


#Examples
cls


#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test1) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#if ($data.Target -eq $rounds*$totalHP) {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Green
#} else {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Red
#}


#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test2) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#if ($data.Target -eq $rounds*$totalHP) {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Green
#} else {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Red
#}


#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test3) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#if ($data.Target -eq $rounds*$totalHP) {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Green
#} else {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Red
#}


#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test4) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#if ($data.Target -eq $rounds*$totalHP) {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Green
#} else {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Red
#}


#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test5) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#if ($data.Target -eq $rounds*$totalHP) {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Green
#} else {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Red
#}


#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test6) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#if ($data.Target -eq $rounds*$totalHP) {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Green
#} else {
#    Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP)) -ForegroundColor Red
#}

#return

#Part 1

#$start = Get-Date

#$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.data) )
#Write-Host "Initially:" -ForegroundColor Magenta
#$data.DrawState()
#$rounds = $data.Run()
#$data.DrawState()
#$totalHP = ($data.Entities().h | measure -Sum).Sum
#if ($data.Entities()[0].t -eq "E") {
#    $t = "Elves"
#} else {
#    $t = "Goblins"
#}
#Write-Host "Combat ends after $rounds full rounds"
#Write-Host "$t win with $totalHP total hitpoints left"
#Write-Host ("Outcome: {0} * {1} = {2}" -f $rounds,$totalHP,($rounds*$totalHP))

#Write-Host ("Part 1 took {1:0.0000} seconds" -f (Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$attack = 3
do {
    $data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.data) )
    write-host (++$attack)
    $rounds = $data.Run($attack)
} until ($data.GameOver -and $data.Entities()[0].t -eq "E")

Write-Host ("Part 2 = Attack:{0} ({1:0.0000})" -f $attack,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
$totalHP = ($data.Entities().h | measure -Sum).Sum
Write-Host "combat ends after $rounds full rounds"
Write-Host "Elves win with $totalhp total hitpoints left"
Write-Host ("outcome: {0} * {1} = {2}" -f $rounds,$totalhp,($rounds*$totalhp))
