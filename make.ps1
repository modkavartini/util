$path = "$env:userProfile\Documents\Adobe\psd"

function make {
    param (
        [string]
        $text = "null",
        [int32]
        $lineMax = 40,
        [int32]
        $start = 1,
        [string]
        $title = "template.psd",
        [switch]
        $continue,
        [switch]
        $im,
        [string]
        $path = $path
    )

    if ((($text -eq "null") -or (!(get-Process "Photoshop" -eA 0))) -and (!($im))) {
        write-Error "requirements were not met! text parameter was not defined and/or photoshop is not running."
        break
    }

    "`n"
    $text = replaceUnicodes($text)
    $preview = $text -replace "\|","`n`n"
    write-Host "$preview" -foregroundColor yellow
    "`n"

    if (!($continue) -and ($start -eq 1)) {
        if (test-Path $path) {
            write-Host "clearing output folder...`n" -foregroundColor red
            get-ChildItem $path -filter c*.png | forEach-Object { $_.delete() }
        }
    }

    else {
        get-ChildItem $path -filter c*.png | forEach-Object { $start++ }
    }

    if (!($im)) {
        for ($t = 5; $t -gt 1; $t--) {
            write-Progress -activity " starting" -status "in:" -secondsRemaining $t
            start-Sleep 1
        }
    }
    
    if (!($im)) {
        nircmd.exe win max ititle "$title"
        nircmd.exe win settopmost ititle "$title" 1
        waitFor 1
    }

    $i = $start
    $text -split "\|" | forEach-Object {
        $current = $_

        $line = ""
        $output = ""
        $words = $current -split ' '
        foreach ($word in $words) {
            if (($line.length + $word.length + 1) -le $lineMax) {
                if ($line -ne "") {
                    $line += ' '
                }
                $line += $word
            }
            else {
                if($output -ne "") {
                    $output += "`n"
                }
                $output += $line
                $line = $word
            }
        }
        if ($output -ne "") {
            $output += "`n"
        }
        $output += $line
        $output = $output

        if (!($im)) {
            set-Clipboard "$output"
            write-Host "starting c$($i):" -foregroundColor yellow
            write-Host "$output`n" -foregroundColor blue
            if (!(get-Process "Photoshop" -eA 0)) { break }
            goAndClick 960 540
            sendKey alt+0xBE
            sendKey ctrl+enter
            sendKey ctrl+v
            waitFor 1
            sendKey esc
            sendKey esc
            if ($i -eq 1) { sendKey ctrl+a }
            sendKey alt+shift+ctrl+q
            #vertical align
            sendKey alt+shift+ctrl+d
            #horizontal align
            sendKey alt+shift+ctrl+g
            #export as png
            waitFor 1
            set-Clipboard "c$i"
            if ($i -eq 1) { waitFor 3 }
            else { waitFor 3 }
            sendKey ctrl+v
            sendKey enter
        }

        else {
            convert "$path\template.png" -gravity center -font "$path\font.otf" -fill "#e1e7fa" -pointsize 37 -annotate 0 "$output" "$path\c$($start).png"
        }

        write-Host "completed c$($i)!`n" -foregroundColor green
        $i++
    }
    if (!($im)) {
        waitFor 1
        nircmd.exe win settopmost ititle "$title" 0
        nircmd.exe win min ititle "$title"
    }
    waitFor 1
    write-Host "completed all $($i-1) tasks!" -foregroundColor red
}

function sendKey($k) {
    waitFor 1
    nircmd.exe sendkeypress $k
}

function waitFor($t) {
    start-Sleep $t
}

function goAndClick($x, $y) {
    nircmd.exe setcursor $x $y
    nircmd.exe sendmouse left click
    waitFor 3
}

function grab {
    param (
        [int32]
        $c = 1,
        [string]
        $skip,
        [switch]
        $na,
        [switch]
        $nr
    )

    $result = ""

    nircmd.exe win max ititle "ssout"
    waitFor 1
    sendKey 0x24
    waitFor 2
    if (!($nr)) {
        sendKey 0x11+0x74
        waitFor 7
    }
    if (!($na)) { attemptIn }

    waitFor 5
    goAndClick 950 220
    waitFor 2
    sendKey ctrl+a
    waitFor 5
    sendKey ctrl+c
    waitFor 5
    goAndClick 950 220
    get-Clipboard | select-String "-.+\d\d:\d\d:\d\d$" -context 1 | forEach-Object {
        $list += $_.context.postContext 
    }
    $j = 1
    $list -split "`n" | forEach-Object {
        if (($j -le $c) -and ($skip -notmatch $j)) {
            $result += $_ + "|"
        }
        $j++
    }
    waitFor 1
    $result = $result -replace "\|$",""
    $result = replaceUnicodes($result)
    set-Clipboard "$result"
    nircmd.exe win min ititle "ssout"
    return $result
}

function replaceUnicodes($uni) {
    $uni = $uni -replace "`u{2764}","`u{1F5A4}"
    $uni = $uni -replace "`u{1FA77}","`u{1F497}"
    return $uni
}

function attemptIn {
    goAndClick 960 295
    waitFor 1
    sendKey 0x43
    sendKey 0x4F
    sendKey 0x4E
    sendKey 0x46
    sendKey 0x45
    sendKey 0x53
    sendKey 0x53
    sendKey 0x49
    sendKey 0x4F
    sendKey 0x4E
    sendKey 0x53
    sendKey 0x4F
    sendKey 0x46
    sendKey 0x43
    sendKey 0x45
    sendKey 0x4B
    waitFor 1
    sendKey enter
    waitFor 1
    sendKey 0x41
    sendKey 0x41
    sendKey 0x52
    sendKey 0x59
    sendKey 0x41
    sendKey 0x4E
    sendKey shift+0x33
    sendKey 0x41
    sendKey 0x42
    sendKey 0x48
    sendKey 0x49
    sendKey 0x52
    sendKey 0x41
    sendKey 0x4D
    sendKey enter
    waitFor 5
}

function p {
    param (
        [int32]
        $c = 1,
        [switch]
        $all
    )
    waitFor 2
    nircmd.exe win max ititle "Instagram"
    waitFor 2
    if ($all) {
        $c = 0
        get-ChildItem $path -filter c*.png | forEach-Object { $c++ }
    }
    for ($l = 1; $l -le $c; $l++) {
        goAndClick 170 690
        goAndClick 960 700
        waitFor 1
        set-Clipboard "$path\c$l.png"
        sendKey ctrl+v
        sendKey enter
        waitFor 2
        goAndClick 1260 245
        goAndClick 1470 245
        goAndClick 1470 245
        waitFor 7
        goAndClick 1865 145
        write-Host "`np'd c$($l)!`n" -foregroundColor green
        waitFor 3
    }
    sendKey 0x11+0x74
    waitFor 2
    nircmd.exe win min ititle "Instagram"
    get-ChildItem $path -filter c*.png | forEach-Object { $_.delete() }
}

function clear-Clip {
    sendKey lwin+d
    sendKey lwin+v
    waitFor 2
    goAndClick 1860 710
    sendKey esc
}

function gmpq($c) {
    make(grab -c $c -nr -na)
    p -all
    clear-Clip
}

function gmp($c) {
    make(grab -c $c)
    p -all
    clear-Clip
}