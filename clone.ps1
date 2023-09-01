$dPath="$env:UserProfile\Documents\Rainmeter\Skins"

function clone {
    param(
        [string]
        $repo = "help",
        [string]
        $name = ($repo -replace '.*/',''),
        [string]
        $path = $dPath
    )
    if (($repo -eq "help") -or ($repo -notmatch "/")) { help }
    $API = invoke-WebRequest -uri "https://api.github.com/repos/$repo/releases/latest" -useBasicParsing
    $branch = ($API | convertFrom-Json).target_commitish
    $zip = "https://github.com/$repo/archive/refs/heads/$branch.zip"
    $outFile = "C:\Windows\Temp\clone.zip"
    write-Host "> downloading source for $repo..." -foregroundColor green
    $WC = new-Object System.Net.WebClient
    $WC.downloadFile($zip, $outFile)
    $outPath = "$path\$name"
    write-Host "> killing rainmeter.exe..." -foregroundColor yellow
    stop-Process -name "Rainmeter" -eA 0
    if (test-Path $outPath) {
        write-Host "> existing $name directory found, deleting..." -foregroundColor yellow
        remove-Item "$outPath" -r -force -confirm:$false
    }
    write-Host "> cloning $repo to $outPath..." -foregroundColor green
    expand-Archive $outFile $path -force
    $folder = ($repo -replace '.*/','') + "-$branch"
    rename-Item "$path\$folder" "$name"
    remove-Item $outFile
    write-Host "> done." -foregroundColor green
}

function help {
    write-Host "required parameter:"
    write-Host "-repo" -foregroundColor red -noNewline
    write-Host " author/repository"
    write-Host "optional parameters:"
    write-Host "-name" -foregroundColor yellow -noNewline
    write-Host " the name of folder to clone to. this is the name of the repository by default."
    write-Host "-path" -foregroundColor yellow -noNewline
    write-Host " the path to clone to in quotes. this is" -noNewline
    write-Host " $dPath" -foregroundColor green -noNewline
    write-Host " by default."
    write-Host "`nexample usage:`nclone -repo modkavartini/catppuccin" -foregroundColor blue
    break
}
