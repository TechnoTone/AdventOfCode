
function loadData ($data) {
    $result = [PSCustomObject]@{
        sourceData = $data
        state = "X"
        minX = 0
        maxX = 0
        minY = 0
        maxY = 0
    } | Add-Member -PassThru -MemberType ScriptProperty -Name Width -Value {
        $this.maxX - $this.minX + 1
    } | Add-Member -PassThru -MemberType ScriptProperty -Name Height -Value {
        $this.maxY - $this.minY + 1
    } | Add-Member -PassThru -MemberType ScriptMethod -Name Show -Value {
        $state = $this.state
        while($state.Length -ge $this.Width){
            Write-Host $state.SubString(0,$this.Width)
            $state = $state.SubString($this.Width)
        }
    } | Add-Member -PassThru -MemberType ScriptMethod -Name XXX -Value {
        
    } 
    
    $dests = generate $result $data.TrimStart("^").TrimEnd("$")

    $result
}

function deDup ($positions) {
    $positions | group X,Y | % {$_.Group[0]}
}

function generate ($data,$instructions,$position=[System.Drawing.Point]::new(0,0)) {
    Write-Host $instructions -ForegroundColor Magenta

    while ($instructions) {
        if ($instructions.StartsWith("(")) {
            $start = 1
            $end = $instructions.LastIndexOf(")")-1
            $section = $instructions.Substring($start,$end)
            deDup (generate $data $section $position)
            $instructions = $instructions.Substring($end+2)
        } else {
            $end = ($instructions+"(").IndexOfAny("()")
            $section = $instructions.Substring(0,$end)
            if ($section.Contains("|")) {
                $section.Split("|") | % {
                    deDup (generate $data $_ $position)
                }
            } else {
                walk $data $section $position
            }
            $instructions = $instructions.Substring($end)
        }
    }
}

function walk ($data,$instructions,$position) {
    $x = $position.X
    $y = $position.Y
    switch ($instructions.ToCharArray()) {
        "N" {
            $y--
            if ($data.minY -eq $y) {
                #add to top of map
            } else {
                
            }
        }
        "E" {
        }
        "S" {
        }
        "W" {
        }
        default {
        }
    }
}

#Examples

$start = Get-Date
$data = loadData "^ENWWW(NEEE|SSE(EE|N))$"

$data.Show()

return

#Part 1

$start = Get-Date

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


