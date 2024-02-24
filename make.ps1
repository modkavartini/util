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
        $clear,
        [string]
        $path = "$env:userProfile\Documents\psd"
    )

    if (($text -eq "null") -or (!(get-Process "Photoshop" -eA 0))) {
        write-Error "requirements were not met! text parameter was not defined and/or photoshop is not running."
        break
    }

    "`n"
    $preview = $text -replace "\|","`n`n"
    write-Host "$preview" -foregroundColor yellow
    "`n"

    if ($clear) {
        if (test-Path $path) {
            write-Host "clearing output folder..." -foregroundColor red
            get-ChildItem $path -filter c*.png | forEach-Object { $_.delete() }
        }
        else {
            write-Error "defined output path was not found!"
            break
        }
    }

    else {
        get-ChildItem $path -filter c*.png | forEach-Object { $start++ }
    }

    write-Host "`npress any key to start...`n" -foregroundColor red
    $null = $host.UI.rawUI.readKey('noEcho,includeKeyDown')

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
    nircmd.exe infobox "tasks completed!" "done!"
    waitFor 1
    nircmd.exe win settopmost title "done!" 1
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
        $c = 0
    )
    $result = ""

    #nircmd.exe win activate ititle "Profile"
    nircmd.exe win max ititle "Profile"
    waitFor 1
    sendKey 0x24
    waitFor 2
    nircmd.exe setcursor 320 958
    #320 945

    for ($j = 0; $j -lt $c; $j++) {
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
