<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/1/19 10:14
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	SetRoboCopyAsAService
	===========================================================================
	.DESCRIPTION
		The function of this script is that it copy files from source to destination.You should modify the file RoboCopyFile.PS1 before you use those scripts base on your environment.
#>

New-Service -Name RoboCopyFile -BinaryPathName "C:\Users\Administrator\SetAsAService\srvany.exe" -DisplayName RoboCopyFile -Description "copy files from source to destination" -StartupType Automatic

$pathRoboCopy = "HKLM:\SYSTEM\CurrentControlSet\services\RoboCopyFile"

New-Item -path $pathRoboCopy -Name Parameters

$pathParameters = "HKLM:\SYSTEM\CurrentControlSet\services\RoboCopyFile\Parameters"

New-ItemProperty -Path $pathParameters -Name AppDirectory -Value C:\Windows\System32\WindowsPowerShell\v1.0 -PropertyType string
New-ItemProperty -Path $pathParameters -Name Application -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy RemoteSigned -File C:\Users\Administrator\SetAsAService\RoboCopyFile.PS1' -PropertyType string

$robocopyStatus = Get-WmiObject -Class Win32_Service -Filter "Name = 'RoboCopyFile'"
if ($robocopyStatus.State -eq "Stopped")
{
		$robocopyStatus.StartService()
}