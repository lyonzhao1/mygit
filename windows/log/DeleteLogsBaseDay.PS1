<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 9:39
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	DeleteLogsBaseDay
	===========================================================================
	.DESCRIPTION
		Delete log files base on day.
#>

# 此处可以填写多个路径,用逗号隔开,如$paths = "C:\logs","D:\logs"
$paths = ""
foreach ($path in $paths)
{
	# 此处没有添加递归参数，只能获得当前目录下的满足条件的日志文件；AddDays(-7)表示只会删除7天以前的.log或.txt文件
	$files = Get-ChildItem -Path $path | Where-Object { $_.PSIsContainer -eq $false } | Where-Object { $_.Name -match ".log" -or $_.Name -match ".txt" } | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
	if ($files.Count -gt 0)
	{
		foreach ($file in $files)
		{
			$filename = $file.FullName
			Remove-Item $filename -Force
			Add-Content "delete.log" "$(Get-Date) Delete $filename successfully"
		}
	}
}