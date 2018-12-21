
function loadData ($data) {
    $result = [PSCustomObject]@{
        sourceData = $data
        state = "X"
        rooms = [System.Collections.ArrayList]::new()
        minX = 0
        maxX = 0
        minY = 0
        maxY = 0
    } | Add-Member -PassThru -MemberType ScriptProperty -Name Width -Value {
        $this.maxX - $this.minX + 1
    } | Add-Member -PassThru -MemberType ScriptProperty -Name Height -Value {
        $this.maxY - $this.minY + 1
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Show -Value {
        $data.rooms | ft X,Y,N,E,S,W | oh

    } | Add-Member -PassThru -MemberType ScriptMethod -Name RoomAt -Value {
        param ([System.Drawing.Point]$location)
        $r = $this.rooms | ?{$_.X -eq $location.X -and $_.Y -eq $location.Y}
        if (!$r) { $r = $this.NewRoom($location) }
        $r
    } | Add-Member -PassThru -MemberType ScriptMethod -Name NewRoom -Value {
        param ([System.Drawing.Point]$location)
        $r = newRoom -Location $location
        $this.rooms.Add($r) | out-null
        $r
    #} | Add-Member -PassThru -MemberType ScriptMethod -Name XXX -Value {        
    } 
    
    $dests = generate $result $data.TrimStart("^").TrimEnd("$")
    Write-Host "Final Destinations:" -ForegroundColor Green
    $dests | ft X,Y | oh

    $result
}

function newRoom([int]$X,[int]$Y,[System.Drawing.Point]$Location) {
    if ($Location) {
        $X = $location.X
        $Y = $location.Y
    }
    [PSCustomObject]@{
        X = $X
        Y = $Y
        N = $null
        E = $null
        S = $null
        W = $null
    }
}

function deDup ($positions) {
    $positions | group X,Y | % {$_.Group[0]}
}

function generate ($data,$instructions,$position=[System.Drawing.Point]::new(0,0)) {
    Write-Host $instructions -ForegroundColor Magenta

    if ($instructions.StartsWith("(")) {
        $start = 1
        $end = $instructions.LastIndexOf(")")-1
        $section = $instructions.Substring($start,$end)
        $positions = generate $data $section $position
        $instructions = $instructions.Substring($end+2)
    } else {
        $end = ($instructions+"(").IndexOfAny("()")
        $section = $instructions.Substring(0,$end)
        if ($section.Contains("|")) {
            $positions = deDup (
                $section.Split("|") | % {
                    $section = $_
                    $positions | % { generate $data $section $_ }
                })
        } else {
            $positions = walk $data $section $position
        }
        $instructions = $instructions.Substring($end)
    }
    if ($instructions) {
        $positions | % { generate $data $instructions $_ }
    } else {
        $positions
    }
}

function walk ($data,$instructions,$position) {
    Write-Host $instructions -ForegroundColor Yellow
    $currentRoom = $data.RoomAt($position)
    switch ($instructions.ToCharArray()) {
        "N" {
                $position.Y--
                $newRoom = $data.RoomAt($position)
                $currentRoom.N = $newRoom
                $newRoom.S = $currentRoom
                $currentRoom = $newRoom
            }
        "E" {
                $position.X++
                $newRoom = $data.RoomAt($position)
                $currentRoom.E = $newRoom
                $newRoom.W = $currentRoom
                $currentRoom = $newRoom
            }
        "S" {
                $position.Y++
                $newRoom = $data.RoomAt($position)
                $currentRoom.S = $newRoom
                $newRoom.N = $currentRoom
                $currentRoom = $newRoom
            }
        "W" {
                $position.X--
                $newRoom = $data.RoomAt($position)
                $currentRoom.W = $newRoom
                $newRoom.E = $currentRoom
                $currentRoom = $newRoom
            }
        default {
                Write-Host "Oh Frell!" -ForegroundColor Yellow -BackgroundColor Red
            }
    }
    return $position
}

#Examples

cls
$start = Get-Date
$data = loadData "^ENWWW(NEEE|SSE(EE|N))$"

$data.Show()


Write-Host ("Part 0 = {0} ({1:0.0000})" -f $answer0,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

return

#Part 1

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


