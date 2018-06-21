<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 13:56
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	MonitorIISAppPool
	===========================================================================
	.DESCRIPTION
		Start the apppool which state is stopped.
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

# 日志记录
$logFile = "monitor_IIS_AppPool.log"

# 运行该函数
StartAppPool