<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 13:58
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	MonitorIISAppPoolSite
	===========================================================================
	.DESCRIPTION
		Start the apppool and site which state is stopped.
#>

# 把停止的应用程序池拉起来
function StartAppPool
{
	$appPoolsInfos = C:\Windows\System32\inetsrv\appcmd.exe list apppool /State:Stopped
	if ($appPoolsInfos)
	{
		foreach ($appPoolsInfo in $appPoolsInfos)
		{
			$appPoolName = $appPoolsInfo.split('"')[1]
			$startResult = C:\Windows\System32\inetsrv\appcmd.exe start apppool $appPoolName
			if ($startResult -match "已成功启动" -or $startResult -match "successfully started")
			{
				Add-Content "$logFile" "$(Get-Date): APPPOOL $appPoolName start successfully."
			}
		}
	}
	else
	{
		Add-Content "$logFile" "$(Get-Date): No APPPOOL is stopped."
	}
}


# 把停止的站点池拉起来
function StartSite
{
	$siteInfos = C:\Windows\System32\inetsrv\appcmd.exe list site /State:Stopped
	if ($siteInfos)
	{
		foreach ($siteInfo in $siteInfos)
		{
			$siteName = $siteInfo.split('"')[1]
			$startResult = C:\Windows\System32\inetsrv\appcmd.exe start site $siteName
			if ($startResult -match "已成功启动" -or $startResult -match "successfully started")
			{
				Add-Content "$logFile" "$(Get-Date): Site $siteName start successfully."
			}
		}
	}
	else
	{
		Add-Content "$logFile" "$(Get-Date): No Site is stopped."
	}
}

# 日志记录
$logFile = "monitor_IIS_AppPool_Site.log"

# 运行应用程序池函数
StartAppPool

# 运行网站函数
StartSite