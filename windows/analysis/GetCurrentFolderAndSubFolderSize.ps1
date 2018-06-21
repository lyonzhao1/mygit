<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 9:58
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	GetCurrentFolderAndSubFolderSize
	===========================================================================
	.DESCRIPTION
		Get the size of current folder and sub-folders 
#>

$ErrorActionPreference = "SilentlyContinue"

Write-Host -ForegroundColor Green "Please be patient......"
Write-Host `t
$currentPath = Get-Location | ForEach-Object { $_.Path }

$totalSize = "{0:N2}" -f ((Get-ChildItem -Recurse | Measure-Object -Property Length -sum).Sum / 1GB)
Write-Host `t
Write-Host "######################################################"
Write-Host "#           current folder and size(GB)              #"
Write-Host "######################################################"
Write-Host `t
Write-Host -ForegroundColor Green "current folder：$currentPath ，total size：$totalSize"

$fds = Get-ChildItem | Where-Object { $_.PsIsContainer -eq $true }
if ($fds.Count)
{
	$output = @()
	foreach ($fd in $fds)
	{
		$fdSize = "{0,9}" -f ("{0:n3}" -f ((Get-ChildItem -Path $fd.FullName -Recurse | Measure-Object -Property Length -sum).Sum / 1GB))
		$fdInfo = '' | Select-Object SubFolderName, SubFolderSize
		$fdInfo.SubFolderName = $fd.Name
		$fdInfo.SubFolderSize = $fdSize
		$output += $fdInfo
	}
	Write-Host `t
	Write-Host "######################################################"
	Write-Host "#           sub folders and size(GB)                 #"
	Write-Host "######################################################"
	
	$output | Sort-Object -Property SubFolderSize -Descending
}
else
{
	Write-Host 	-ForegroundColor Red "There is no sub folders in current folder."
}
[Console]::ReadKey()