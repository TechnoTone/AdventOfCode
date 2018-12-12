
function getState($data) {
    $data[0].Substring(15)
}

function getRules($data) {
    $rules=@{}
    $data | select -Skip 2 | ? {$_.EndsWith("#")} | % {$r=$_ -split " => "; $rules[$r[0]]=$r[1]}
    $rules
}

function getScore($state,$start) {
    $score=0
    @(0..($state.Length-1))|%{
        if($state[$_] -eq "#") {$score+=$_+$start}
    }
    $score
}

function spread($state,$rules) {
    while ($state.Substring($state.Length-2).Contains("#")){$state+="."}
    $state='..'+$state+'..'
    $next=''
    @(0..($state.Length-5))|%{
        $k=$state.Substring($_,5)
        if ($rules.ContainsKey($k)) {
            $next+=$rules[$k]
        } else {
            $next+="."
        }
    }
    $next
}

#Examples

#$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day12test.data)

#$state = "..." + (getState $data)
#$rules = getRules $data

#cls
#$rules | oh
#Write-Host $state (getScore $state -3)

#@(1..20)|%{
#    $state = spread $state $rules
#    Write-Host $state (getScore $state -3)
#}


#Part 1

$start = Get-Date

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day12.data)

$state = "..." + (getState $data)
$rules = getRules $data

#cls
#$rules | oh
#Write-Host $state (getScore $state -3)

@(1..20)|%{
    $state = spread $state $rules
    #Write-Host $state (getScore $state -3)
}

$answer1 = getScore $state -3


Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day12.data)

$state = "..." + (getState $data)
$rules = getRules $data

#cls
#$rules | oh
#Write-Host $state (getScore $state -3)

@(1..200)|%{
    $state = spread $state $rules
    #Write-Host $state (getScore $state -3)
}

$score = getScore $state -3
$nextScore = getScore (spread $state $rules) -3

$diff = $nextScore-$score
$answer2 = $bigScore = (50000000000 - 200) * $diff + $score

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
