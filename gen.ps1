$path = "$env:userProfile\Documents\Adobe\psd"

function gen {
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
        write-Host "starting in:`n" -foregroundColor yellow
        for ($t = 5; $t -ge 1; $t--) {
            write-Host "$t" -foregroundColor yellow -noNewline
            for ($i = 0; $i -lt $t; $i++) { write-Host "." -foregroundColor yellow -noNewline }
            write-Host ""
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
            if ((get-Process | select-Object  mainWindowTitle | select-String "template.psd") -notmatch "template.psd") {
                write-Error "photoshop document not found!"
                break
            }
            #if (!(get-Process "Photoshop" -eA 0)) { break }
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
        sendKey ctrl+s
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

function tabChoose($e) {
    waitFor 2
    for ($o = 0; $o -lt $e; $o++) {
        sendKey 0x09
    }
    sendKey enter
}

function grab {
    param (
        [int32]
        $c = 1,
        [string]
        $skip,
        [switch]
        $nr
    )

    $result = ""
    nircmd.exe win min ititle "ssout"
    waitFor 1
    nircmd.exe win max ititle "ssout"
    waitFor 1
    if ((get-Process | select-Object  mainWindowTitle | select-String "ssout") -notmatch "ssout") {
        write-Error "tab/process not found!"
        break
    }
    sendKey 0x24
    waitFor 2
    if (!($nr)) {
        sendKey 0x11+0x74
        waitFor 7
    }
    if (((get-Process | select-Object  mainWindowTitle | select-String "ssout") -match "Login")) { attemptIn }
    sendKey 0x24
    waitFor 5
    goAndClick 950 220
    waitFor 2
    sendKey ctrl+a
    waitFor 5
    sendKey ctrl+c
    waitFor 5
    goAndClick 950 220
    get-Clipboard | select-String "-.+\d\d:\d\d:\d\d$" -context 1 | forEach-Object {
        $add = $_.context.postContext
        $mal = 0
        for ($m = 0; $m -lt $add.length; $m++) {
            if ($add[$m] -match "[\u0D00-\u0D7F]+") {
                $mal = 1
                break
            }
        }
        if (($add -notin $list) -and ($mal -eq 0)) { $list += $_.context.postContext }
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
    tabChoose 2
    set-Clipboard (get-Content "$path\idp.env" -totalCount 1)
    sendKey ctrl+v
    waitFor 1
    sendKey enter
    waitFor 1
    set-Clipboard (get-Content "$path\idp.env" -tail 1)
    sendKey ctrl+v
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
    goAndClick 175 750
    waitFor 4

    if ($all) {
        $c = 0
        get-ChildItem $path -filter c*.png | forEach-Object { $c++ }
    }
    for ($l = $c; $l -gt 0; $l--) {
        if ((get-Process | select-Object  mainWindowTitle | select-String "Instagram") -notmatch ".+c.k.+c.+s.+") {
            write-Error "tab/process/account not found!"
            break
        }
        goAndClick 170 690
        tabChoose 1
        waitFor 1
        set-Clipboard "$path\c$l.png"
        sendKey ctrl+v
        sendKey enter
        waitFor 2
        tabChoose 2
        tabChoose 2
        tabChoose 2
        waitFor 7
        tabChoose 1
        write-Host "`nposted c$($l)!" -foregroundColor green
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
    tabChoose 2
    sendKey esc
}

#macros

function ggpq($c) {
    gen(grab -c $c -nr)
    p -all
    clear-Clip
}

function ggpqim($c) {
    gen(grab -c $c -nr) -im
    p -all
    clear-Clip
}

function ggp($c) {
    gen(grab -c $c)
    p -all
    clear-Clip
}

function ggpim($c) {
    gen(grab -c $c) -im
    p -all
    clear-Clip
}

function ggpio($n) {
    $l = $n[-1]
    for ($i = 1; $i -le $l; $i++) {
        if ("$n" -notmatch "$i") {
            $s += "$i, "
        }
    }
    $s = $s -replace ", $",""
    $s = $s -replace "^$","0"
    $c = $l
    write-Host "`nexcluded $s." -foregroundColor blue
    
    gen(grab -c $c -skip "$s")
    p -all
    clear-Clip
}