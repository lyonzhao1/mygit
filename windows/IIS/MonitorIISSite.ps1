<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 11:39
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	MonitorIISSite
	===========================================================================
	.DESCRIPTION
		Start the site which state is stopped.
#>

#把停止的站点池拉起来
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

#日志记录
$logFile = "monitor_IIS_Site.log"

#运行该函数
StartSite