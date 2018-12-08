

$start = Get-Date

$data = cat (Join-Path (Join-Path ($PSCommandPath | Split-Path -Parent | Split-Path -Parent) Data) Day08.data)
$data = $data -split " " | % {[int]$_}

function node() {
    @{
        Children = @()
        MetaData = @()
    }
}


function parseData ($context) {
    $newNode = node
    $children = $context.data[$context.Offset++]
    $metas = $context.data[$context.Offset++]
    while ($children -gt 0) {
        $newNode.Children = $newNode.Children + (parseData $context)
        $children--
    }
    while ($metas -gt 0) {
        $newNode.MetaData = $newNode.MetaData + ($context.data[$context.Offset++])
        $metas--
    }
    return $newNode
}

$context = @{
    Data = $data
    Offset = 0
}

$tree = parseData $context

#function displayTree ($node, [int]$indent=0) {
#    if ($node) {
#        write-host (" "*$indent)($node.ID)"["($node.MetaData)"]"
#        $node.Children | % {displayTree $_ ($indent+1)}
#    }
#}

#displayTree $tree

#Part 1

function sumMetaData ($node) {
    $md = 0
    if ($node) {
        $node.MetaData | % {$md += $_}
        $node.Children | % {sumMetaData $_} | % {$md += $_}
    }
    $md
}

$answer1 = sumMetaData $tree


Write-Host ("Part 1 = {0} ({1})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

function sumMetaData2 ($node) {
    $md = 0
    if ($node) {
        if ($node.Children.Count -eq 0) {
            $node.MetaData | % {$md += $_}
        } else {
            foreach ($i in $node.MetaData) {
                if ($node.Children[$i-1]) {
                    $md += sumMetaData2 ($node.Children[$i-1])
                } else {
                }
            }
        }
    }
    return $md
}


$answer2 = sumMetaData2 $tree

Write-Host ("Part 2 = {0} ({1})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan


