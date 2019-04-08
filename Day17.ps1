
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
        $x = $x-$this.xmin
        $y = $y-$this.yMin
        $this.grid[$y][$x]
    } | Add-Member -PassThru -MemberType ScriptMethod -Name "setCell" -Value {
        param ($x,$y,$value)
        $x = $x-($this.xMin)
        $y = $y-($this.yMin)
        $this.grid[$y] = ($this.grid[$y]).Remove($x,1).Insert($x,$value)
    } | Add-Member -PassThru -MemberType ScriptMethod -Force -Name "displayGrid" -Value {
        $this.grid
    }

    $data.setCell(500, 0, $cellSpring)
    
    $coords | % { $data.setCell( $_.X, $_.Y, $cellClay ) }

    return $data
        
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


