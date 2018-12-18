
function show ($recipes, $a, $b) {
    $i = 0
    while ($i -lt $recipes.Length) {
        if ($i -eq $a) {
            Write-Host ("({0})" -f $recipes[$i]) -NoNewline
        } elseif ($i -eq $b) {
            Write-Host ("[{0}]" -f $recipes[$i]) -NoNewline
        } else {
            Write-Host (" {0} " -f $recipes[$i]) -NoNewline
        }
        $i++
    }
    Write-Host
}

#Examples

#$recipes = @(3,7)
#$a=0
#$b=1

#while ($recipes.Count -lt 2028) {
#    #show $recipes $a $b
#    $new = $recipes[$a]+$recipes[$b]
#    if ($new -gt 9) {
#        $recipes = $recipes + @(1,($new-10))
#    } else {
#        $recipes = $recipes + $new
#    }
#    $a = ($a + 1 + $recipes[$a]) % $recipes.Count
#    $b = ($b + 1 + $recipes[$b]) % $recipes.Count
#}

#$recipes[9..18] -join ""
#$recipes[5..14] -join ""
#$recipes[18..27] -join ""
#$recipes[2018..2027] -join ""


#Part 1

$start = Get-Date

$recipes = @(3,7)
$a=0
$b=1

while ($recipes.Count -lt 47801+9) {
    #show $recipes $a $b
    $new = $recipes[$a]+$recipes[$b]
    if ($new -gt 9) {
        $recipes = $recipes + @(1,($new-10))
    } else {
        $recipes = $recipes + $new
    }
    $a = ($a + 1 + $recipes[$a]) % $recipes.Count
    $b = ($b + 1 + $recipes[$b]) % $recipes.Count
}

$recipes -join ""
$answer1 = ($recipes[47801..47810] -join "")

Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$searchFor = "047801"
$recipes = New-Object System.Collections.ArrayList
$recipes.AddRange(@(3,7)) | Out-Null

$a=0
$b=1

$last7 = "-"*7

while ($last7 -notmatch $searchFor) {

    $new = ($recipes[$a])+($recipes[$b])
    if ($new -gt 9) {
        $recipes.AddRange(@(1, ($new-10))) | Out-Null
        $last7 = $last7.Substring(2)+$new.ToString()
    } else {
        $recipes.Add($new) | Out-Null
        $last7 = $last7.Substring(1)+$new.ToString()
    }

    $a = ($a + 1 + $recipes[$a]) % $recipes.Count
    $b = ($b + 1 + $recipes[$b]) % $recipes.Count
}

$answer2 = $recipes.Count - 7 + $last7.IndexOf($searchFor)

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
