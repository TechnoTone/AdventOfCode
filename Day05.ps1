
$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day05.data)

$regEx = [regex]"aA|Aa|bB|Bb|cC|Cc|dD|Dd|eE|Ee|fF|Ff|gG|Gg|hH|Hh|iI|Ii|jJ|Jj|kK|Kk|lL|Ll|mM|Mm|nN|Nn|oO|Oo|pP|Pp|qQ|Qq|rR|Rr|sS|Ss|tT|Tt|uU|Uu|vV|Vv|wW|Ww|xX|Xx|yY|Yy|zZ|Zz"


#Part 1

$start = Get-Date

while ($data -and $regEx.IsMatch($data)) {
    $data = $regEx.Replace($data, "")
}

Write-Host ("Part 1 = {0} ({1:0.0000} seconds)" -f $data.Length,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


#Part 2

$start = Get-Date

$results = @()

foreach ($n in @(65..90)) {
    $regEx2 = [regex]([char]$n+"|"+[char]($n+32))
    $data2 = $regEx2.Replace($data, "")
    while ($data2 -and $regEx.IsMatch($data2)) {
        $data2 = $regEx.Replace($data2, "")
    }
    $results = $results + $data2.Length
}

Write-Host ("Part 2 = {0} ({1:0.0000} seconds)" -f ($results | measure -Minimum).Minimum,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
