
function nObj($t,$x,$y) {
    [PSCustomObject]@{t=$t;x=$x;y=$y;h=200
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
    $target = [int]$data[-1]
    $map = $data[0..($data.Count-2)]
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
        $this.ObjectTypes.Count -le 2
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
        $this.Objects | ? {$_.h -le 0} | % {
            updateMap $this.Map $_.x $_.y "."
        }
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
        $round = 0
        while (!$this.GameOver) {
            $entities = $this.Entities()
            foreach ($entity in $entities) {
                if ($entity.h) {
                    if (!($this.HasEnemyNeighbour($entity))) {
                        $path = $this.ShortestPathToEnemy($entity)
                        if ($path) {
                            #Write-Host $entity,"Move",$path.Count
                            $this.MoveEntity($entity,$path[1].x,$path[1].y)
                        } else {
                            #Write-Host $entity,"Wait"
                        }
                    }
                    if ($this.HasEnemyNeighbour($entity)) {
                        $target = $this.GetEnemyNeighbour($entity)
                        #Write-Host $entity,"Fight",$target
                        $target.h = $target.h -3
                    }
                }
            }
            #return
            $this.BringOutYourDead()
            $round++
            #Write-Host "After round $round" -ForegroundColor Magenta
            #$this.DrawState()
            if ($round -ge 26) { 
                #pause
            }
        }
        Write-Host "Game Over after $round rounds"
        $totalHP = ($this.Entities().h | measure -Sum).Sum
        Write-Host "Hitpoints remaining: $totalHP"
        Write-Host "Outcome:" ($totalHP*$round)
    } 
}


#Examples
cls


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test1) )
Write-Host "Initially:" -ForegroundColor Magenta
$data.DrawState()
$data.Run()
$data.DrawState()


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test2) )
Write-Host "Initially:" -ForegroundColor Magenta
$data.DrawState()
$data.Run()
$data.DrawState()


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test3) )
Write-Host "Initially:" -ForegroundColor Magenta
$data.DrawState()
$data.Run()
$data.DrawState()


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test4) )
Write-Host "Initially:" -ForegroundColor Magenta
$data.DrawState()
$data.Run()
$data.DrawState()


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test5) )
Write-Host "Initially:" -ForegroundColor Magenta
$data.DrawState()
$data.Run()
$data.DrawState()


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test6) )
Write-Host "Initially:" -ForegroundColor Magenta
$data.DrawState()
$data.Run()
$data.DrawState()


return

#Part 1

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day15.data)

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

