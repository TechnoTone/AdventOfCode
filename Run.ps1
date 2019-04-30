git log -10 --format=format:'%s' | 
    grep 'Day\s*\d+' | 
    select -First 1 * -ExpandProperty Matches | 
    select -ExpandProperty Value |
    % {$_ -replace " ",""} |
    % {cls; . ".\$_.ps1"}
