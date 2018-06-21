<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/5 10:05
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	RestartIISSiteAfterKillW3WPProcess
	===========================================================================
	.DESCRIPTION
		For yong jia wang luo' environment, when the problem which CPU percent is larger than 90% and some site occurs 502 Bad Gateway is 
	triggered, the script is executed immediately.
#>
# log file
$logFile = "restart_site.log"

Get-Date | Out-File $logFile -Append

# get the w3wp process which use the longgest cpu time
$processInfo = Get-Process | Where-Object { $_.ProcessName -match "w3wp" } | Sort-Object CPU -Descending | Select-Object -First 1
$id = $processInfo.Id

"The w3wp id which takes a log of CPU time is $id" | Out-File $logFile -Append

# the function is that it gets the site name base on the w3wp process
function GetSiteName
{
	param($id)
	$wpInfo = C:\Windows\System32\inetsrv\appcmd.exe list wp | Where-Object{ $_ -match "$id" }
	$nameInfo = $wpInfo.Split(":")[-1]
	$appPoolName = $nameInfo.Split(')')[0]
	$siteInfo = C:\Windows\System32\inetsrv\appcmd.exe list app /apppool.name:"$appPoolName"
	if ($siteInfo.Count)
	{
		$siteName = $siteInfo[0].split("/")[0].split('"')[1]
		$siteName
	}
	else
	{
		$siteName = $siteInfo.split("/")[0].split('"')[1]
		$siteName
	}
}

$siteName = GetSiteName -id $id

"The site name which will be restart is $siteName" | Out-File $logFile -Append

# stop the w3wp process forcely
Stop-Process -Id $id -Force

# stop the site
C:\Windows\System32\inetsrv\appcmd.exe stop site "$siteName" | Out-File $logFile -Append
# start the site
C:\Windows\System32\inetsrv\appcmd.exe start site "$siteName" | Out-File $logFile -Append
Get-Date | Out-File $logFile -Append
