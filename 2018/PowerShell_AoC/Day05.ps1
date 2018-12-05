$start = Get-Date

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day05.data)

$regEx = [regex]"aA|Aa|bB|Bb|cC|Cc|dD|Dd|eE|Ee|fF|Ff|gG|Gg|hH|Hh|iI|Ii|jJ|Jj|kK|Kk|lL|Ll|mM|Mm|nN|Nn|oO|Oo|pP|Pp|qQ|Qq|rR|Rr|sS|Ss|tT|Tt|uU|Uu|vV|Vv|wW|Ww|xX|Xx|yY|Yy|zZ|Zz"


#Part 1
while ($data -and $regEx.IsMatch($data)) {
    $data = $regEx.Replace($data, "")
}

Write-Host ("Part 1 = {0} ({1})" -f $data.Length,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$results = @()
foreach ($n in @(65..90)) {
    $regEx2 = [regex]([char]$n+"|"+[char]($n+32))
    $data2 = $regEx2.Replace($data, "")
    while ($data2 -and $regEx.IsMatch($data2)) {
        $data2 = $regEx.Replace($data2, "")
    }
    $results = $results + $data2.Length
}

Write-Host ("Part 2 = {0} ({1})" -f ($results | measure -Minimum).Minimum,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
