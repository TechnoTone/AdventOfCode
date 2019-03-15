
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
        $enemies = $this.GetEnemies($entity)
        foreach ($enemy in $enemies) {
            if ($enemy.x -eq $entity.x -and ((abs ($enemy.y-$entity.y)) -le 1) -or
                ($enemy.y -eq $entity.y -and ((abs ($enemy.x-$entity.x)) -le 1))) {
                return $enemy
            }
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "HasEnemyNeighbour" -Value {
        param ($entity)
        [bool]($this.GetEnemyNeighbour($entity))
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "BringOutYourDead" -Value {
        $this.Objects = $this.Objects | ? {$_.h -gt 0}
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "ShortestPathToEnemy" -Value {
        param ($entity)
        $t = $entity.t.ToString().ToLower()
        $map = $this.Map.Clone()
        $stack = New-Object System.Collections.Stack
        $stack.Push(@($entity.GetLocation()))
        while ($stack.Count) {
            $path = $stack.Pop()
            $x = $path[-1].x
            $y = $path[-1].y
            if ($this.HasEnemyNeighbour((nObj $t $x $y))) {
                return $path
            } else {
                if ($map[$y-1][$x] -eq ".") {
                    updateMap $map ($y-1) $x $t
                    #$map[$y-1] = $map[$y-1].Remove($x,1).Insert($x,$t)
                    $stack.Push($path+(nLoc $x ($y-1)))
                }
                if ($map[$y][$x-1] -eq ".") {
                    updateMap $map $y ($x-1) $t
                    #$map[$y] = $map[$y].Remove($x-1,1).Insert($x-1,$t)
                    $stack.Push($path+(nLoc ($x-1) $y))
                }
                if ($map[$y][$x+1] -eq ".") {
                    updateMap $map $y ($x+1) $t
                    #$map[$y] = $map[$y].Remove($x+1,1).Insert($x+1,$t)
                    $stack.Push($path+(nLoc ($x+1) $y))
                }
                if ($map[$y+1][$x] -eq ".") {
                    updateMap $map ($y+1) $x $t
                    #$map[$y+1] = $map[$y+1].Remove($x,1).Insert($x,$t)
                    $stack.Push($path+(nLoc $x ($y+1)))
                }
            }
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "Run" -Value {
        $round = 0
        while (!$this.GameOver) {
            Write-Host "Round $round"
            $this.Map | oh

            $entities = $this.Entities()
            foreach ($entity in $entities) {
                if ($entity.h) {
                    if (!($this.HasEnemyNeighbour($entity))) {
                        $path = $this.ShortestPathToEnemy($entity)
                        Write-Host $entity,"Move",$path.Count
                        $this.MoveEntity($entity,$path[1].x,$path[1].y)
                    }
                    if ($this.HasEnemyNeighbour($entity)) {
                        $target = $this.GetEnemyNeighbour($entity)
                        Write-Host $entity,"Fight",$target
                    }
                }
            }
            #return
            $this.BringOutYourDead()
            $round++
        }
        Write-Host "Game Over after $round rounds"
    } 
}


#Examples
cls


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) .\Day15.test1) )
$data.Run()

return

#Part 1

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day15.data)

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

