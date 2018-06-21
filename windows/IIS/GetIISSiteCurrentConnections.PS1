<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 14:04
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	GetIISSiteCurrentConnections
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

# 获取站点信息
$siteInfos = C:\Windows\System32\inetsrv\appcmd.exe list site

$output = @()

foreach ($siteInfo in $siteInfos)
{
	# 获取站点名称
	$siteName = $siteInfo.split('"')[1]
	# 获取站点连接数
	$siteConnections = (Get-Counter -Counter "\Web Service($siteName)\Current Connections").CounterSamples | ForEach-Object { $_.CookedValue }
	# 构建输出哈希表
	$connectInfo = '' | Select-Object siteName, siteConnections
	$connectInfo.siteName = $siteName
	$connectInfo.siteConnections = $siteConnections
	$output += $connectInfo
}

$output
[System.Console]::ReadKey()