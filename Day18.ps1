
function loadData ($data) {
    @{
        sourceData = $data
        width = $data[0].Length
        height = $data.Count
        state = (" " * ($data[0].Length+3)) + ($data -join "  ") + (" " * ($data[0].Length+3))
        answer = $null
    } | Add-Member -PassThru -MemberType ScriptMethod -Name CoordToInt -Value {
        param( [int] $x, [int] $y )
        $y*($this.width+2)+$x
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Acre -Value {
        param( [int] $x, [int] $y )
        $this.state.SubString($this.CoordToInt($x,$y),1)
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Neighbours -Value {
        param( [int] $x, [int] $y )
        $loc = $this.CoordToInt($x,$y)
        $w=$this.width
        $h=$this.height
        $this.state[$loc-$w-3]+$this.state[$loc-$w-2]+$this.state[$loc-$w-1]+
        $this.state[$loc-1]+$this.state[$loc+1]+
        $this.state[$loc+$w+1]+$this.state[$loc+$w+2]+$this.state[$loc+$w+3]
    } | Add-Member -PassThru -MemberType ScriptMethod -Name CountAcres -Value {
        param( $acres )
        if (!$acres) {$acres = $this.state}
        if ($acres -is [string]) {$acres = $acres.ToCharArray()}
        @{
            Trees = ($acres -match "\|").Count
            Lumberyards = ($acres -match "\#").Count
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name CountNeighbours -Value {
        param( [int] $x, [int] $y )
        $this.CountAcres($this.Neighbours($x,$y))
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Tick -Value {
        $w=$this.width
        $h=$this.height
        $state = " "*($w+2)
        for ($y=1; $y -le $h; $y++) {
            $state+=" "
            for ($x=1; $x -le $w; $x++) {
                $counts = $this.CountNeighbours($x,$y)
                $a = $this.Acre($x,$y)
                switch ($a) {
                    "." {if ($counts.Trees -ge 3) {$a="|"}}
                    "|" {if ($counts.Lumberyards -ge 3) {$a="#"}}
                    "#" {if ($counts.Lumberyards -ge 1 -and $counts.Trees -ge 1) {$a="#"} else {$a="."}}
                }
                $state+=$a
            }
            $state+=" "
        }
        $this.state = $state + " "*($w+2)
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Show -Value {
        $state = $this.State.SubString($this.width+2)
        $w=$this.width+2
        while($state.Length -gt $w){
            Write-Host $state.SubString(1,$this.width)
            $state = $state.SubString($this.width+2)
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name GetHash -Value {
        $this.state | Get-Hash | select -ExpandProperty HashString
    }
}

#Examples

#$start = Get-Date
#$data = loadData (cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day18test.data))

#cls
#Write-Host "Initial state:" -ForegroundColor Green
#$data.Show()
#@(1..10)|%{
#    Write-Host "`nAfter $_ minutes:" -ForegroundColor Green
#    $data.Tick()
#    $data.Show()
#}

#$data.answer = $data.CountAcres()
#$data.answer = $data.answer.Trees * $data.answer.Lumberyards

#Write-Host ("Example = {0} ({1:0.0000})" -f $data.answer,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
#return

#Part 1

$start = Get-Date
$data = loadData (cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day18.data))

$history = New-Object System.Collections.ArrayList
$history.Add($data.GetHash()) | Out-Null

@(1..10)|%{
    $data.Tick()
    $history.Add($data.GetHash()) | Out-Null
}

$data.answer = $data.CountAcres()
$data.answer = $data.answer.Trees * $data.answer.Lumberyards


Write-Host ("Part 1 = {0} ({1:0.0000})" -f $data.answer,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$start = Get-Date
$count=10
for(;;) {
    $data.Tick()
    $hash = $data.GetHash()
    $count++
    if ($history.Contains($hash)) {
        #Write-Host "`nAfter $count minutes:" -ForegroundColor Green
        #$data.Show()
        if ((1000000000 - $count )%($count - $history.LastIndexOf($hash)) -eq 0) {
            break
        }
    }
    $history.Add($hash) | Out-Null
}

$data.answer = $data.CountAcres()
$data.answer = $data.answer.Trees * $data.answer.Lumberyards


Write-Host ("Part 2 = {0} ({1:0.0000})" -f $data.answer,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
