$dPath="$env:UserProfile\Documents\Rainmeter\Skins"

function clone {
    param(
        [string]
        $repo = "help",
        [string]
        $cloneTo = $dPath
    )
    if($repo -eq "help") { help }
    $API=invoke-WebRequest -uri "https://api.github.com/repos/$repo/releases/latest" -useBasicParsing
    $branch=($API | convertFrom-Json).target_commitish
    $zip="https://github.com/$repo/archive/refs/heads/$branch.zip"
    $outFile="C:\Windows\Temp\clone.zip"
    write-Host "> downloading source for $repo..." -foregroundColor green
    $WC=new-Object System.Net.WebClient
    $WC.downloadFile($zip, $outFile)
    $name=$repo -replace '.*/',''
    $outPath="$cloneTo\$name"
    if(test-Path $outPath) {
        write-Host "> existing $name directory found, deleting..." -foregroundColor yellow
        remove-Item "$outPath" -r -force -confirm:$false
    }
    write-Host "> cloning $repo to $outPath..." -foregroundColor green
    expand-Archive $outFile $cloneTo -force
    rename-Item "$outPath-$branch" "$name"
    remove-Item $outFile
    write-Host "> done." -foregroundColor green
}

function help {
    write-Host "required parameter:"
    write-Host "-repo" -foregroundColor red -noNewline
    write-Host " author/repository"
    write-Host "optional parameter:"
    write-Host "-cloneTo" -foregroundColor yellow -noNewline
    write-Host " the path to clone to in quotes. this is" -noNewline
    write-Host " $dPath" -foregroundColor green -noNewline
    write-Host " by default."
    write-Host "`nexample usage:`nclone -repo modkavartini/catppuccin" -foregroundColor blue
    break
}
