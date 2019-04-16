
$cellInvalid = ' '
$cellEmpty = '.'
$cellClay = '#'
$cellSpring = '+'
$cellWaterFalling = '|'
$cellWaterFlat = '~'


function parseCoordinates($lines) {
    foreach ($line in $lines) {
        $values = ($line -split ", ") | % {($_ -split "=")[1]}
        $range = $values[1] -split "\.\."
        @($range[0]..$range[1]) | % {
            if ($line.StartsWith("x")) {
                [PSCustomObject]@{X=$values[0];Y=$_}
            } else {
                [PSCustomObject]@{X=$_;Y=$values[0]}
            }
        }
    }
}

function nLoc($x,$y){
    [PSCustomObject]@{x=$x;y=$y}
}

function parseData($lines) {

    $coords = parseCoordinates $lines
    $xMin = ($coords.X | Measure-Object -Minimum).Minimum
    $xMax = ($coords.X | Measure-Object -Maximum).Maximum
    $yMin = ($coords.Y | Measure-Object -Minimum).Minimum
    $yMax = ($coords.Y | Measure-Object -Maximum).Maximum

    if ($yMin -gt 0) {$yMin = 0}

    $dx = $xMax - $xMin
    $dy = $yMax - $yMin

    $grid = @()

    @(0..$dy) | % {
        $grid = $grid + [string]::new($cellEmpty,$dx+1)
    }

    $data = [PSCustomObject]@{
        grid=$grid
        xMin=$xMin
        xMax=$xMax
        yMin=$yMin
        yMax=$yMax
        width=$dx
        height=$dy
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "getCell" -Value {
        param ($x,$y)
        if ($this.validCell($x,$y)) {
            $x = $x-$this.xmin
            $y = $y-$this.yMin
            $this.grid[$y][$x]
        } else {
            $cellInvalid
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "setCell" -Value {
        param ($x,$y,$value)
        $x = $x-($this.xMin)
        $y = $y-($this.yMin)
        $this.grid[$y] = ($this.grid[$y]).Remove($x,1).Insert($x,$value)
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "displayGrid" -Value {
        $this.grid
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "validCell" -Value {
        param ($x,$y)
        $x -ge $this.xMin -and $x -le $this.xMax -and $y -ge $this.yMin -and $y -le $this.yMax
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "flow" -Value {
        param ($x,$y)
        $this.setCell($x, $y, $cellSpring)
        $route = New-Object System.Collections.Stack
        $queue = New-Object System.Collections.Queue
        if ($this.getCell($x,($y+1)) -ne $cellClay) {
            $queue.Enqueue((nLoc $x ($y+1)))
        } else {
            if ($this.getCell(($x-1),$y) -ne $cellClay) {
                $queue.Enqueue((nLoc ($x-1) $y))
            }
            if ($this.getCell(($x+1),$y) -ne $cellClay) {
                $queue.Enqueue((nLoc ($x+1) $y))
            }
        }
        
        cls
        $this.grid | oh
        while ($queue.Count) {
            $next = $queue.Dequeue();
            $x = $next.x
            $y = $next.y
            if ($this.getCell($x,($y+1)) -eq $cellEmpty) {
                $this.setCell($x,$y,$cellWaterFalling)
                $route.Push((nLoc $x $y))
                $queue.Enqueue((nLoc $x ($y+1)))
            } else {
                $this.setCell($x,$y,$cellWaterFlat)
                $route.Push((nLoc $x $y))
                if ($this.getCell(($x-1),$y) -eq $cellEmpty) {
                    $queue.Enqueue((nLoc ($x-1) $y))
                }
                if ($this.getCell(($x+1),$y) -eq $cellEmpty) {
                    $queue.Enqueue((nLoc ($x+1) $y))
                }
                if ($queue.Count -eq 0) {
                    $r = $route.ToArray()
                    $i = 0
                    while ($i -le $r.Count -and $this.getCell(($r[$i].x),($r[$i].y)) -ne $cellWaterFalling) {
                        $i++
                    }
                    $x = $r[$i].x
                    $y = $r[$i].y
                    if ($this.getCell($x,$y) -eq $cellWaterFalling) {
                        $this.setCell($x,$y,$cellWaterFlat)
                        if ($this.getCell(($x-1),$y) -eq $cellEmpty) {
                            $queue.Enqueue((nLoc ($x-1) $y))
                        }
                        if ($this.getCell(($x+1),$y) -eq $cellEmpty) {
                            $queue.Enqueue((nLoc ($x+1) $y))
                        }
                    }
                }
            }
            cls
            $this.grid | oh
            #pause
        }
    }

    
    $coords | % { $data.setCell( $_.X, $_.Y, $cellClay ) }

    return $data
        
}


$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day17.test) )


$data
$data.flow(500,0)

return
#Examples




#Part 1

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


