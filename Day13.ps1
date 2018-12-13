
$cartChars = "^>v<"
$trackTurns = "\+/"

function getCarts ($data) {

    $width = $data[0].Length-1
    $height = $data.Count-1

    @(0..$height)|%{
        $y=$_
        @(0..$width)|%{
            $x=$_
            $c = ($data[$y][$x])
            if ($cartChars.IndexOf($c)+1) {
                newCart $x $y $c
            }
        }
    }

}

function newCart([int]$x,[int]$y,[Char]$d) {
    [PSCustomObject]@{
        X=$x
        Y=$Y
        Direction=$d
        Turn=0
    }
}

function moveUp($cart,$data) {
    $x = $cart.X
    $y = $cart.Y - 1
    $cart.Y = $y

    $c = $data[$y][$x]
    switch ($c) {
        "\" {$cart.Direction = "<"}
        "+" {   switch ($cart.Turn){
                    0 {$cart.Direction = "<"}
                    2 {$cart.Direction = ">"}
                }
                $cart.Turn = ($cart.Turn+1)%3
            }
        "/" {$cart.Direction = ">"}
    }
}

function moveDown($cart,$data) {
    $x = $cart.X
    $y = $cart.Y + 1
    $cart.Y = $y

    $c = $data[$y][$x]
    switch ($c) {
        "\" {$cart.Direction = ">"}
        "+" {   switch ($cart.Turn){
                    0 {$cart.Direction = ">"}
                    2 {$cart.Direction = "<"}
                }
                $cart.Turn = ($cart.Turn+1)%3
            }
        "/" {$cart.Direction = "<"}
    }
}

function moveLeft($cart,$data) {
    $x = $cart.X - 1
    $y = $cart.Y
    $cart.X = $x

    $c = $data[$y][$x]
    switch ($c) {
        "\" {$cart.Direction = "^"}
        "+" {   switch ($cart.Turn){
                    0 {$cart.Direction = "v"}
                    2 {$cart.Direction = "^"}
                }
                $cart.Turn = ($cart.Turn+1)%3
            }
        "/" {$cart.Direction = "v"}
    }
}

function moveRight($cart,$data) {
    $x = $cart.X + 1
    $y = $cart.Y
    $cart.X = $x

    $c = $data[$y][$x]
    switch ($c) {
        "\" {$cart.Direction = "v"}
        "+" {   switch ($cart.Turn){
                    0 {$cart.Direction = "^"}
                    2 {$cart.Direction = "v"}
                }
                $cart.Turn = ($cart.Turn+1)%3
            }
        "/" {$cart.Direction = "^"}
    }
}

function tick($carts,$data) {

    $crashes = 0

    foreach ($cart in $carts){
        switch ($cart.Direction) {
            "^" {moveUp $cart $data; break}
            ">" {moveRight $cart $data; break}
            "v" {moveDown $cart $data; break}
            "<" {moveLeft $cart $data; break}
            "X" {$crashes++; break}
        }
        $collides = $carts|?{$_.X -eq $cart.X -and $_.Y -eq $cart.Y}
        if ($collides.Count -gt 1){
            $collides|?{$_.Direction -ne "X"} |% {
                $_.Direction = "X"
                $crashes++
            }
        }
    }

    $crashes
}

function showMe($carts,$data){
    
}

#Examples

#$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day13test.data)

#$width = $data[0].Length
#$height = $data.Count

#cls
#$data

#$carts = getCarts $data
#$data = $data | % {$_.Replace("<","-").Replace(">","-").Replace("^","|").Replace("v","|")}
#$carts | oh

#$cartCount = [int]($carts|?{$_.Direction -ne "X"}).Count
#$crashes = 0
#$moves = 0

#while (!$crashes){
#    $crashes = tick $carts $data
#    $moves++
#    #write-host $moves $carts
#}

#Write-Host "Moves: $moves "
#$carts | oh

#return


#$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day13test2.data)

#$width = $data[0].Length
#$height = $data.Count

#cls
#$data

#$carts = getCarts $data
#$data = $data | % {$_.Replace("<","-").Replace(">","-").Replace("^","|").Replace("v","|")}
#$carts | oh

#$cartCount = [int]($carts|?{$_.Direction -ne "X"}).Count
#$crashes = 0
#$moves = 0

#while ($carts.Count -gt 1){
#    $crashes = tick $carts $data
#    if ($crashes) {
#        $carts = $carts | ? {$_.Direction -ne "X"}
#    }
#    $moves++
#}

#Write-Host "Moves: $moves "
#$carts | oh


#return


#Part 1

#$start = Get-Date

#$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day13.data)

#$width = $data[0].Length
#$height = $data.Count

#$carts = getCarts $data
#$data = $data | % {$_.Replace("<","-").Replace(">","-").Replace("^","|").Replace("v","|")}

#$cartCount = [int]($carts|?{$_.Direction -ne "X"}).Count
#$crashes = 0

#while (!$crashes){
#    $crashes = tick $carts $data
#}

#$answer1 = $carts|?{$_.Direction -eq "X"}|select -First 1|%{"{0},{1}" -f $_.X,$_.Y}

#Write-Host ("Part 1 = {0} ({1:0.0000})" -f $answer1,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan



#Part 2

$start = Get-Date

$data = cat (Join-Path ($PSCommandPath | Split-Path -Parent) Day13.data)

$width = $data[0].Length
$height = $data.Count

$carts = getCarts $data
$data = $data | % {$_.Replace("<","-").Replace(">","-").Replace("^","|").Replace("v","|")}

$cartCount = [int]($carts|?{$_.Direction -ne "X"}).Count
$crashes = 0
$moves = 0

while ($carts.Count -gt 1){
    $crashes = tick $carts $data
    if ($crashes) {
        $carts = $carts | ? {$_.Direction -ne "X"}
    }
    $moves++
    #showMe $carts $data
}

Write-Host "$moves moves"
$answer2 = $carts|select -First 1|%{"{0},{1}" -f $_.X,$_.Y}

Write-Host ("Part 2 = {0} ({1:0.0000})" -f $answer2,(Get-Date).Subtract($start).TotalSeconds) -ForegroundColor Cyan
