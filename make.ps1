$path = "$env:userProfile\Documents\psd"

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
        [string]
        $path = $path
    )

    if (($text -eq "null") -or (!(get-Process "Photoshop" -eA 0))) {
        write-Error "requirements were not met! text parameter was not defined and/or photoshop is not running."
        break
    }

    "`n"
    $preview = $text -replace "\|","`n`n"
    write-Host "$preview" -foregroundColor yellow
    "`n"

    if (!($continue)) {
        if (test-Path $path) {
            write-Host "clearing output folder...`n" -foregroundColor red
            get-ChildItem $path -filter c*.png | forEach-Object { $_.delete() }
        }
    }

    else {
        get-ChildItem $path -filter c*.png | forEach-Object { $start++ }
    }

    #write-Host "`npress any key to start...`n" -foregroundColor red
    #$null = $host.UI.rawUI.readKey('noEcho,includeKeyDown')

    for ($t = 5; $t -gt 1; $t--) {
        write-Progress -activity " starting" -status "in:" -secondsRemaining $t
        start-Sleep 1
    }
    
    #nircmd.exe win activate ititle "$title"
    nircmd.exe win max ititle "$title"
    nircmd.exe win settopmost ititle "$title" 1
    waitFor 1

    $i = $start
    $text = $text -replace "`u{2764}","`u{1F5A4}"
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
        set-Clipboard "$output"

        write-Host "starting c$($i):" -foregroundColor yellow
        write-Host "$output`n" -foregroundColor blue
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
        write-Host "completed c$($i)!`n" -foregroundColor green
        $i++
    }
    waitFor 1
    nircmd.exe win settopmost ititle "$title" 0
    nircmd.exe win min ititle "$title"
    #nircmd.exe infobox "tasks completed!" "done!"
    waitFor 1
    #nircmd.exe win settopmost title "done!" 1
    write-Host "completed all $($i-1) tasks!" -foregroundColor red
}

function sendKey($k) {
    waitFor 1
    nircmd.exe sendkeypress $k
}

function waitFor($t) {
    start-Sleep $t
}

function grab {
    param (
        [int32]
        $c = 0,
        [switch]
        $alive
    )
    $result = ""

    nircmd.exe win max ititle "Profile"
    waitFor 1
    sendKey 0x24
    sendKey 0x11+0x74
    waitFor 12
    if (!($alive)) { attemptIn }
    nircmd.exe setcursor 320 958

    for ($j = 0; $j -lt $c; $j++) {
        waitFor 1
        nircmd.exe sendmouse left dblclick
        nircmd.exe sendmouse left dblclick
        #sendKey shift+0x23
        sendKey ctrl+c
        waitFor 1
        $result += get-Clipboard
        $result += "|"
        if ($j -lt ($c-1)) {
            nircmd.exe movecursor 0 -1.5
            nextGrab
        }
    }
    $result = $result -replace "\|$",""
    set-Clipboard "$result"
    nircmd.exe win min ititle "Profile"
    return $result
}

function nextGrab {
    for ($k = 0; $k -lt 3; $k++) {
        sendKey 0x28
        waitFor 0.1
    }
}

function attemptIn {
    goAndClick -x 960 -y 295
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
}

function goAndClick {
    param (
        [int32]
        $x,
        [int32]
        $y
    )
    nircmd.exe setcursor $x $y
    nircmd.exe sendmouse left click
    waitFor 2
}

function p {
    param (
        [int32]
        $c = 1
    )
    waitFor 2
    nircmd.exe win max ititle "Instagram"
    waitFor 2
    for ($l = 1; $l -le $c; $l++) {
        goAndClick -x 170 -y 690
        goAndClick -x 960 -y 700
        waitFor 1
        set-Clipboard "$path\c$l.png"
        sendKey ctrl+v
        sendKey enter
        waitFor 2
        goAndClick -x 1260 -y 245
        goAndClick -x 1470 -y 245
        goAndClick -x 1470 -y 245
        waitFor 5
        goAndClick -x 1865 -y 145
        write-Host "p'd c$($l)!`n" -foregroundColor green
        waitFor 3
    }
    nircmd.exe win min ititle "Instagram"
}
