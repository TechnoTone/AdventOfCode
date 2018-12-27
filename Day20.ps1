
function loadData ($data) {
    $data = $data.TrimStart("^").TrimEnd("$")
    
    [PSCustomObject]@{
        sourceData = $data
        map = walk $data
    #} | Add-Member -PassThru -MemberType ScriptMethod -Name XXX -Value {        
    }
}

function newMap() {
    [PSCustomObject]@{
        rooms = @{}
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Walk -Value {
        param ($room)
        $key = $room.key
        $r = $this.rooms[$key]
        if ($r) {
            if ($r.distance -gt $room.distance) {
                $r.distance = $room.distance
            } else {
                #$room.distance = $r.distance
            }
        } else {
            $this.rooms[$key] = $room
        }
    }
}

function newRoom([int]$x,[int]$y, [int]$distance, [string]$road) {
    [PSCustomObject]@{
        x = $x
        y = $y
        distance = $distance
        #road = $road
    } | Add-Member -PassThru -MemberType ScriptProperty -Name "key" -Value {"{0},{1}" -f $this.x,$this.y}
}

function walk ($data) {

    #Write-Host "BREAKDOWN: $data" -ForegroundColor Magenta

    $room = newRoom 0 0 0 ""
    $stack = New-Object System.Collections.Stack
    $map = newMap

    foreach ($char in $data.ToCharArray()) {
        switch ($char) {
            "(" {
                    $stack.Push($room)
                }
            ")" {
                    $room = $stack.Pop()
                }
            "|" {
                    $room = $stack.Peek()
                }
        }
        if ("NESW".Contains($char)) {
            switch ($char) {
                "N" {$room = newRoom ($room.x) ($room.y+1) ($room.distance+1) } #($room.road+$char)}
                "E" {$room = newRoom ($room.x+1) ($room.y) ($room.distance+1) } #($room.road+$char)}
                "S" {$room = newRoom ($room.x) ($room.y-1) ($room.distance+1) } #($room.road+$char)}
                "W" {$room = newRoom ($room.x-1) ($room.y) ($room.distance+1) } #($room.road+$char)}
            }
            if ($room.distance -ge 19) {
                Out-Null -InputObject "agh!"
            }
            $map.Walk($room)
        }
    }

    $map
}


#Examples

#cls

#$data = loadData "^ENWWW(NEEE|SSE(EE|N))$"
#$data.map.rooms.Values | sort distance | select -last 1 | ft distance #should be 10
##$data.map.rooms.Values | sort y,x | ft

#$data = loadData "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$"
#$data.map.rooms.Values | sort distance | select -last 1 | ft distance #should be 18
##$data.map.rooms.Values | sort y,x | ft

#$data = loadData "^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$"
#$data.map.rooms.Values | sort distance | select -last 1 | ft distance #should be 23
##$data.map.rooms.Values | sort y,x | ft

#$data = loadData "^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$"
#$data.map.rooms.Values | sort distance | select -last 1 | ft distance #should be 31
##$data.map.rooms.Values | sort y,x | ft

#return

#Part 1

$start = Get-Date
$data = loadData (cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day20.data))
$answer1 = $data.map.rooms.Values | sort distance | select -last 1 | select -ExpandProperty distance
Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan

#Part 2

$start = Get-Date
$answer2 = $data.map.rooms.Values | ? {$_.distance -ge 1000} | measure | select -ExpandProperty Count
Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
