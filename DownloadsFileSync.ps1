$sourcePath = "C:\Users\YourUsername\Downloads"
$destinationPath = "\\YourServer\YourShare"
$fileExtensions = @("exe", "msi", "iso", "img")
$pattern = "[A-Za-z]+"
$timeSpan = New-TimeSpan -Seconds 600

while ($true) {
    $now = Get-Date
    
    $files = Get-ChildItem -Path $sourcePath -File | Where-Object {
        $_.LastWriteTime -gt $now.Subtract($timeSpan) -and
        $fileExtensions -contains $_.Extension.TrimStart('.').ToLower()
    }

    foreach ($file in $files) {        
        $extensionFolder = Join-Path -Path $destinationPath -ChildPath $file.Extension.ToLower()
        if(-not (Test-Path -Path $extensionFolder))
        {
            New-Item -ItemType Directory -Path $extensionFolder
        }
        
        if ($file.BaseName -match $pattern) 
        {            
            $subfolder = [regex]::Match($file.Name, $pattern).Value
            $destFolder = Join-Path -Path $extensionFolder -ChildPath $subfolder

            if (-not (Test-Path -Path $destFolder)) 
            {
                New-Item -ItemType Directory -Path $destFolder
            }            
        }
        else
        {
            $destFolder = $extensionFolder
        }
        
        Copy-Item -Path $file.FullName -Destination "$($destFolder)\$($now.ToString("yyyy-MM-dd"))_$($file.Name)" -Force
    }

    Start-Sleep -Seconds $timeSpan.TotalSeconds
}
