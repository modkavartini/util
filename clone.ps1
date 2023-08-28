function clone {
    param(
        [string]
        $repo,
        [string]
        $cloneTo = "$env:UserProfile\Documents\Rainmeter\Skins"
    )
    $API=invoke-WebRequest -uri "https://api.github.com/repos/$repo/releases/latest" -useBasicParsing
    $branch=($API | convertFrom-Json).target_commitish
    $zip="https://github.com/$repo/archive/refs/heads/$branch.zip"
    $outFile="C:\Windows\Temp\clone.zip"
    write-Host "> downloading $repo..." -foregroundColor red
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
