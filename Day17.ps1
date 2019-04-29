
$cellInvalid = ' '
$cellEmpty = '.'
$cellClay = '#'
$cellSpring = '+'
$cellWaterFalling = '|'
$cellWaterFlat = '~'

$left = -1
$right = 1

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
    $xMin = ($coords.X | Measure-Object -Minimum).Minimum - 1
    $xMax = ($coords.X | Measure-Object -Maximum).Maximum + 1
    $yMin = ($coords.Y | Measure-Object -Minimum).Minimum
    $yMax = ($coords.Y | Measure-Object -Maximum).Maximum

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
        $this.grid[$y] = ($this.grid[$y]).Remove($x,($value.Length)).Insert($x,$value)
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "displayGrid" -Value {
        $this.grid | Out-Host
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "validCell" -Value {
        param ($x,$y)
        $x -ge $this.xMin -and $x -le $this.xMax -and $y -ge $this.yMin -and $y -le $this.yMax
    } | Add-Member -PassThru -MemberType ScriptProperty -Force -Name "waterCellCount" -Value {
        return ($this.grid | % {$_.ToCharArray() | ? {$_ -in ($cellWaterFalling,$cellWaterFlat)}}).Count
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "flow" -Value {
        param ($x,$y)
        if ($y -lt $this.yMin) {
            $y = $this.yMin 
            $this.setCell($x, $y, $cellWaterFalling)
            $result = 1
        } else {
            $this.setCell($x, $y, $cellSpring)
            $result = 0
        }
        do {
            $n = $this.addWater($x,$y+1)
            $result += $n
            #$this.displayGrid()
            Write-Host $result
        }
        while ($n)
        return $result
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "addWater" -Value {
        param ($x,$y)

        if ($this.getCell($x,$y) -eq $cellWaterFalling) {return 0}    # END!

        do {
            
            $cell = $this.getCell($x,$y)
            $cellNext = $this.getCell($x,$y+1)
            if ($cellNext -in ($cellInvalid,$cellWaterFalling)) {         # END!
                $this.setCell($x,$y,$cellWaterFalling)
                return 1
           }
            
            if ($cellNext -eq $cellEmpty) {                               # flowing down
                $y++
                $direction = $null
                continue
            }
                                                                          # on clay or still water
            $left=$x
            $right=$x

            while ($this.getCell($left-1,$y) -ne $cellClay -and $this.getCell($left,$y+1) -in ($cellClay,$cellWaterFlat)) {
                $left--
            }
            $cellLeft = $this.getCell($left,$y+1)

            while ($this.getCell($right+1,$y) -ne $cellClay -and $this.getCell($right,$y+1) -in ($cellClay,$cellWaterFlat)) {
                $right++
            }
            $cellRight = $this.getCell($right,$y+1)

            if ($cellLeft -eq $cellEmpty) {
                $x = $left
                $y = $y+1
                continue
            }

            if ($cellRight -eq $cellEmpty) {
                $x = $right
                $y = $y+1
                continue
            }

            if ($cellLeft -eq $cellWaterFalling -and $cellRight -eq $cellWaterFalling) {
                $this.setCell($left,$y,($cellWaterFalling * ($right-$left+1)))
                return ($right-$left+1)
            }

            if (($cellLeft -eq $cellWaterFalling -and $cellRight -eq $cellWaterFlat) -or 
                ($cellLeft -eq $cellWaterFlat -and $cellRight -eq $cellWaterfalling)) {
                $this.setCell($left,$y,($cellWaterFalling * ($right-$left+1)))
                return ($right-$left+1)
            }

            if ($cellLeft -in ($cellClay,$cellWaterFlat) -and $cellRight -in ($cellClay,$cellWaterFlat)) {
                $this.setCell($left,$y,($cellWaterFlat * ($right-$left+1)))
                return ($right-$left+1)
            }


            ### THIS SHOULD NEVER HAPPEN !!
            write-host "==============" -ForegroundColor Cyan
            Write-Host $x,$y
            continue 

        } until (0)
    }
    
    $coords | % { $data.setCell( $_.X, $_.Y, $cellClay ) }
    
    return $data
}


#Example
cls
$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day17.test) )

$data.displayGrid()
$result = $data.flow(500,0)
Write-Host $result -ForegroundColor Cyan
$data.displayGrid()
Write-Host $result -ForegroundColor Cyan



#Part 1

$start = Get-Date

$data = parseData ( cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day17.data) )
cls
$result = $data.flow(500,0)
Write-Host ("Part 1: {0} ({1:0.0000})" -f $result,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$result2 = ($data.grid | % {$_.ToCharArray() | ? {$_ -in ($cellWaterFlat)}}).Count
Write-Host ("Part 2: {0} ({1:0.0000})" -f $result2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
