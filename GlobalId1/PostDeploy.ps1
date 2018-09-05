$SourceDirectory =   "$($OctopusParameters["OctopusOriginalPackageDirectoryPath"])"
$TargetDirectory = ''
$ExcludeExtentions = ".ps1|-Staging.config|.nuspec|packages.config"

switch ($($OctopusParameters["Octopus.Environment.Name"]))
	{
		"test" {
			$TargetDirectory = @('http://localhost:80')		 
		}		
		default { 
			Write-Error "Could not determine which environment to deploy to.  Terminating."
			Exit 1
		}
	}

$DestinationDirectory = "\\$($TargetDirectory)\GlobalID1\"  #include the final back slash


Write-Host "Clearing the remote directory"
Remove-Item "$($DestinationDirectory)*" -Recurse

Write-Host "Getting List of Files to Copy"
$files = Get-ChildItem $SourceDirectory -Recurse

Write-Host "Copying Files"
try
{
	foreach ($file in $files)
	{
		if ($file.FullName -notmatch $ExcludeExtentions)
		{
			Write-Host "Copying File $($file.FullName)"
			$CopyPath = Join-Path $DestinationDirectory $file.FullName.Substring($SourceDirectory.length)
			Copy-Item $file.FullName -Destination $CopyPath
		}
	}
}
catch
{
	exit 1
	Write-Hosts ("PostDeploy Powershell script failed to complete: " + $_)
}
