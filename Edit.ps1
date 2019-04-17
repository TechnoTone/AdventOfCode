git log -10 --format=format:'%s' | 
    grep 'Day\d+' | 
    select -First 1 * -ExpandProperty Matches | 
    select -ExpandProperty Value |
    % {psedit "$_.ps1"}
