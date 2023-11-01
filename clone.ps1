$dPath = "$env:userProfile\Documents\Rainmeter\Skins"

function clone {
    param(
        [string]
        $repo = "help",
        [string]
        $branch = "0",
        [string]
        $name = ($repo -replace '.*/',''),
        [string]
        $path = $dPath
    )
    if ($repo -match ".+\\.+") { write-Host "`n> mf it's / not \ !!! xddd" -foregroundColor blue }
    if (($repo -eq "help") -or ($repo -notmatch ".+/.+")) { help }
    $status = try { ((invoke-WebRequest -uri "https://api.github.com/repos/$repo" -useb).StatusCode) -replace '200','found' } catch { "not found" }
    $sColor = if ($status -eq "found") { "green" } else { "red" }
    write-Host "> repo $status!" -foregroundColor $sColor
    if ($status -ne "found") { break }
    if ($branch -eq 0) {
        $branch = ((invoke-WebRequest -uri "https://api.github.com/repos/$repo" -useb) | convertFrom-Json).default_branch
        write-Host "> found default branch: $branch" -foregroundColor green
    }
    $zip = "https://github.com/$repo/archive/refs/heads/$branch.zip"
    $outFile = "C:\Windows\Temp\clone.zip"
    write-Host "> downloading source for $repo/tree/$branch..." -foregroundColor green
    $WC = new-Object System.Net.WebClient
    $WC.downloadFile($zip, $outFile)
    $rm = get-Process "Rainmeter" -eA 0
    $rmPath = $rm.path
    if ($path -eq "home") {
        $path = $env:userProfile
        $rm = $false
    }
    $drive = $path -replace ':\\.*',''
    if (!(test-Path ($drive + ":\"))) {
        write-Host "> the specified drive $drive does not exist!" -foregroundColor red
        break
     }
    if (!(test-Path $path)) { write-Host "> the specified folder at $path was not found!`n> creating it..." -foregroundColor yellow }
    if ($rm) { 
    write-Host "> killing Rainmeter.exe..." -foregroundColor yellow
    stop-Process -name "Rainmeter" -eA 0
    }
    $outPath = "$path\$name"
    if (test-Path $outPath) {
        write-Host "> existing $name directory found!`n> checking for active processes from directory..." -foregroundColor yellow
        get-ChildItem $outPath -filter *.exe -r | forEach-Object {
            if (get-Process $_.baseName -eA 0) {
                write-Host "> killing $($_.baseName).exe..." -foregroundColor red
                stop-Process -name $_.baseName -eA 0
            }
        }
        write-Host "> deleting existing $name directory..." -foregroundColor yellow
        remove-Item "$outPath" -r -force -confirm:$false
    }
    write-Host "> cloning $repo to $outPath..." -foregroundColor green
    expand-Archive $outFile $path -force
    $folder = ($repo -replace '.*/','') + "-$branch"
    rename-Item "$path\$folder" "$name"
    remove-Item $outFile -force -confirm:$false
    if ($rm) { 
        write-Host "> starting Rainmeter.exe..." -foregroundColor green
        start-Process $rmPath
    }
    write-Host "> done." -foregroundColor green
}

function help {
    write-Host "`nrequired parameter:"
    write-Host "-repo" -foregroundColor red -noNewline
    write-Host " author/repository"
    write-Host "`noptional parameters:"
    write-Host "-branch" -foregroundColor yellow -noNewline
    write-Host " the branch to clone. this is automatically fetched by default."
    write-Host "-name" -foregroundColor yellow -noNewline
    write-Host " the name of folder to clone to. this is the name of the repository by default."
    write-Host "-path" -foregroundColor yellow -noNewline
    write-Host " the path to clone to in" -noNewline
    write-Host " quotes" -foregroundColor red -noNewline
    write-Host ". this is" -noNewline
    write-Host " $dPath" -foregroundColor green -noNewline
    write-Host " by default.`n use" -noNewLine
    write-Host " home" -foregroundColor blue -noNewLine 
    write-Host " to clone to" -noNewLine 
    write-Host " $env:userProfile" -foregroundColor green -noNewLine 
    write-Host "."
    # i fucking hate this fuck you powershell <3
    write-Host "`nexample usage:" -foregroundColor blue
    write-Host "clone -repo modkavartini/catppuccin" -foregroundColor red -noNewLine 
    write-Host " -branch main -name cat_bussin -path `"D:\Rainmeter\Skins`"" -foregroundColor yellow
    break
}

# print help on iex :3
clone
