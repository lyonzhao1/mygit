<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/5 16:17
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	InitializeScriptForWindows
	===========================================================================
	.DESCRIPTION
		Initialize script for Windows Server 2008R2/2012R2/2016
#>

# gernerate the random password
function GernerateRanPwd
{
	$chars = "1", "4", "3", "r", "2", "5", "8", "@", "7", "9", "0", "Q", "W", "E", "%", "R", "T", "Y", "U", "I", "P", "S", "F", "G", "(", "H", "J", "K", "L", "Z", "X", "&", "C", "V", "B", "N", "M", "q", "w", "e", "t", "y", "A", "u", "i", "o", "-", "p", "a", "6", "s", "d", "f", "#", "g", "h", "j", "O", "k", "l", "z", "x", "c", "v", "b", "D", "n", "m", "~", "!", "$", "^", "*", ")", "+"
	$pwd = ""
	for ($i = 0; $i -le 11; $i++)
	{
		$pwd += Get-Random -InputObject $chars
	}
	$pwd
}

# set the password never expires
function SetPwdAndNoExpires
{
	param ($needSetPwdAccount)
	
	$userPwd = GernerateRanPwd
	$setPwdInfo = net user $needSetPwdAccount $userPwd
	if ($setPwdInfo[0] -match "命令成功完成" -or $setPwdInfo[0] -match "completed successfully")
	{
		Write-Host -ForegroundColor Green "the password of $needSetPwdAccount has been modified， please update $userPwd to RatticDB."
	}
	else
	{
		Write-Host -ForegroundColor Red "failed to modify the password for $newAdmin, please check the cause."
	}
	$accountInfo = Get-WmiObject -Class Win32_UserAccount -Filter "Name='$needSetPwdAccount'"
	$accountInfo | Set-WmiInstance -Arguments @{ PasswordExpires = 0 } | Out-Null
}

# rename Administratorto zyadmin
$newAdmin = "zyadmin"

function ChangeAdminName
{
	param ($adminName)
	if (Get-WmiObject -Class Win32_UserAccount -Filter "Name='$newAdmin'")
	{
		Write-Host -ForegroundColor Red "The account zyadmin already exists."
	}
	else
	{
		$userInfo = Get-WmiObject -Class Win32_UserAccount -Filter "Name='Administrator'"
		if ($userInfo)
		{
			$userValue = $userInfo.Rename($adminName)
			if ($userValue.ReturnValue -eq 0)
			{
				Write-Host -ForegroundColor Green "The account Administrator has been renamed to $adminName"
			}
			else
			{
				Write-Host -ForegroundColor Red "The account Administrator renamed failed, please check the cause."
			}
		}
		else
		{
			Write-Host -ForegroundColor Red "The account Administrator dose not exist, maybe has been renamed already."
		}
	}
}

# modify the description for account zyadmin
$commentInfo = "account for zhuyun"
function ChangeComment
{
	param ($commInfo)
	$setCommentInfo = net user $newAdmin /comment:$commentInfo
	if ($setCommentInfo[0] -match "命令成功完成" -or $setCommentInfo[0] -match "completed successfully")
	{
		Write-Host -ForegroundColor Green "the description for $newAdmin has been modified to $commentInfo"
	}
	else
	{
		Write-Host -ForegroundColor Red "failed to modify the description to $newAdmin, please check the cause."
	}
}

# create new user and add the user to the administrators group 

function CreateUserAndAddToGroup
{
	param ($newUser)
	
	# create new user
	$addUser = net user $newUser 1qaz@WSX /add
	if ($addUser[0] -match "命令成功完成" -or $addUser[0] -match "completed successfully")
	{
		Write-Host -ForegroundColor Green "the new user $newUser creates successfully"
	}
	else
	{
		Write-Host -ForegroundColor Red "the new user $newUser creates failed, please check the cause."
	}
	
	
	# add the user to administrators group
	$addToGroup = net localgroup administrators $newUser /add
	if ($addToGroup[0] -match "命令成功完成" -or $addToGroup[0] -match "completed successfully")
	{
		Write-Host -ForegroundColor Green "the user $newUser has been added to administrators group successfully."
	}
	else
	{
		Write-Host -ForegroundColor Red "the user $newUser failed to be added the administrators group, please check the cause."
	}
}


# enable remote desktop
function EnableRdp
{
	$terminalService = Get-WmiObject -Class Win32_TerminalServiceSetting -Namespace "root\cimv2\TerminalServices"
	if ($terminalService.AllowTSConnections -eq 0)
	{
		$tsResult = $terminalService.SetAllowTSConnections(1)
		if ($tsResult.ReturnValue -eq 0)
		{
			Write-Host -ForegroundColor Green "Has been enabled the remote desktop successfully."
		}
	}
}

function DisUserAuthRequired
{
	$GeneralService = Get-WmiObject -Class Win32_TSGeneralSetting -Namespace "root\cimv2\TerminalServices" -Filter "TerminalName='RDP-Tcp'"
	$GeneralService.SetUserAuthenticationRequired(0) | Out-Null
}


# modify the port to 40022 for remote desktop
function ChangeRdpPort
{
	$newPort = "40022"
	$setRdpInfo = Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber -Value "$newPort"
	$seTcpInfo = Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" -Name PortNumber -Value "$newPort"
	
	$newRdpInfo = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name PortNumber
	$newTcpInfo = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" -Name PortNumber
	
	if ($newRdpInfo.PortNumber -eq "$newPort" -and $newTcpInfo.PortNumber -eq "$newPort")
	{
		Write-Host -ForegroundColor Green "The port of remote desktop has been modified to $newPort"
	}
	else
	{
		Write-Host -ForegroundColor Red "Failed to modify the port for remote desktop."
	}
}

function ChangeGroupPolicyAndRegedit
{
	# enable more sessions for one account
	$sessionPerUser = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fSingleSessionPerUser
	if ($sessionPerUser.fSingleSessionPerUser -ne "0")
	{
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fSingleSessionPerUser -Value 0
	}

	$displayUserName = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System | ForEach-Object{$_.dontdisplaylastusername}
	if($displayUserName -ne 1)
	{
		Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name dontdisplaylastusername -Value 1
	}

	$restrictAnonymous = Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa | ForEach-Object{$_.restrictanonymous}
	if($restrictAnonymous -ne 1)
	{
		Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa -Name restrictanonymous -Value 1
	}

	# change values for group policy
	SecEdit.exe /export /cfg C:\Windows\Temp\gp.inf | Out-Null
	(Get-Content C:\Windows\Temp\gp.inf) -replace "MinimumPasswordLength = 0","MinimumPasswordLength = 8" | Out-File C:\Windows\Temp\gp.inf
	(Get-Content C:\Windows\Temp\gp.inf) -replace "PasswordHistorySize = 0","PasswordHistorySize = 3" | Out-File C:\Windows\Temp\gp.inf
	SecEdit.exe /configure /db C:\Windows\Temp\gp.sdb /cfg C:\Windows\Temp\gp.inf | Out-Null
	Remove-Item C:\Windows\Temp\gp.sdb -Force
	Remove-Item C:\Windows\Temp\gp.inf -Force
}

# disable services below
$disableServices = "ALG", "AppMgmt", "Browser", "TrkWks", "hidserv", "iphlpsvc", "WPDBusEnum", "Spooler", "CertPropSvc", "DPS", "WdiServiceHost", "fdPHost", "FDResPub", "swprv", "wercplsupport", "ShellHWDetection", "SCardSvr", "SCPolicySvc", "AudioSrv", "AudioEndpointBuilder", "WerSvc", "Wecsvc"

function DisableService
{
	param ($disableServiceName)
	$serviceInfo = Get-WmiObject Win32_Service -Filter "Name = '$disableServiceName'"
	if ($serviceInfo.State -eq "Running")
	{
		$stopResult = $serviceInfo.StopService()
		if ($stopResult.ReturnValue -eq 0)
		{
			Write-Host -ForegroundColor Green "$disableServiceName has been stopped."
		}
		else
		{
			Write-Host -ForegroundColor Red "$disableServiceName not be stopped, please check the cause."
		}
	}
	if ($serviceInfo.StartMode -ne "Disabled")
	{
		$changeResult = $serviceInfo.change($null, $null, $null, $null, "Disabled", $null, $null, $null, $null, $null, $null)
		if ($changeResult.ReturnValue -eq 0)
		{
			Write-Host -ForegroundColor Green "The start type of $disableServiceName has been modified to disabled"
		}
		else
		{
			Write-Host -ForegroundColor Red "Failed to modify the start type of $disableServiceName, please check the cause."
		}
	}
}

# start the service below
$enableServices = "BFE", "BITS", "SharedAccess", "PolicyAgent", "SessionEnv"

function EnableService
{
	param ($enableServiceName)
	$serviceInfo = Get-WmiObject Win32_Service -Filter "Name = '$enableServiceName'"
	if ($serviceInfo.StartMode -ne "Auto")
	{
		$changeResult = $serviceInfo.change($null, $null, $null, $null, "Automatic", $null, $null, $null, $null, $null, $null)
		if ($changeResult.ReturnValue -eq 0)
		{
			Write-Host -ForegroundColor Green "The start type of $enableServiceName has been modified to automatic"
		}
		else
		{
			Write-Host -ForegroundColor Red "Failed to modify the start type of  $enableServiceName, please check the cause."
		}
	}
	if ($serviceInfo.State -eq "Stopped")
	{
		$startResult = $serviceInfo.StartService()
		if ($startResult.ReturnValue -eq 0)
		{
			Write-Host -ForegroundColor Green "$enableServiceName has been started."
		}
		else
		{
			Write-Host -ForegroundColor Red "$enableServiceName not be started, please check the cause."
		}
	}
}

# the function below is to rename the hostname
function ChangeHostname
{
	param ($newName)
	$hostnameInfo = Get-WmiObject -Class Win32_ComputerSystem
	$nameValue = $hostnameInfo.Rename("$newName")
	if ($nameValue.ReturnValue -eq 0)
	{
		Write-Host -ForegroundColor Green "The hostname has been renamed to $newName, it will take effect after reboot the system."
	}
	else
	{
		Write-Host -ForegroundColor Red "Failed to rename the hostname, please check the cause."
	}
}


# the function below is to reboot the server
function RebootServer
{
	$rebootInfo = Get-WmiObject -Class Win32_OperatingSystem -EnableAllPrivileges
	$rebootType = $rebootInfo.Reboot()
	if ($rebootType.ReturnValue -eq 0)
	{
		Write-Host -ForegroundColor Green "The server is rebooting......"
	}
	else
	{
		Write-Host -ForegroundColor Red "The server reboots failed, please check the cause."
	}
}

# add test to image
function AddTextToImage 
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][String] $sourcePath,
        [Parameter(Mandatory=$true)][String] $destPath,
        [Parameter(Mandatory=$true)][String] $title,
        [Parameter(Mandatory=$true)][String] $description,
        [Parameter(Mandatory=$true)][String] $cpu,
        [Parameter(Mandatory=$true)][String] $mem
    )
 
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
     
    $srcImg = [System.Drawing.Image]::FromFile($sourcePath)
    $bmpFile = new-object System.Drawing.Bitmap([int]($srcImg.width)),([int]($srcImg.height))
    $Image = [System.Drawing.Graphics]::FromImage($bmpFile)
    $Image.SmoothingMode = "AntiAlias"
    $Rectangle = New-Object Drawing.Rectangle 0, 0, $srcImg.Width, $srcImg.Height
    $Image.DrawImage($srcImg, $Rectangle, 0, 0, $srcImg.Width, $srcImg.Height, ([Drawing.GraphicsUnit]::Pixel))
 
    $Font = new-object System.Drawing.Font("Verdana",24)
    $Brush = New-Object Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255,255,0,0))
    $Image.DrawString($title, $Font, $Brush, 1200, 100)
    $Image.DrawString($description, $Font, $Brush, 1200, 160)
    $Image.DrawString($cpu, $Font, $Brush, 1200, 220)
    $Image.DrawString($mem, $Font, $Brush, 1200, 280)
 
    $bmpFile.save($destPath, [System.Drawing.Imaging.ImageFormat]::Bmp)
    $bmpFile.Dispose()
    $srcImg.Dispose()
}

# The data disk is offline after run sysprep on ECS, the function is that set the disk online.
function SetDiskOnlineFor2008R2
{
	$signatures = Get-WmiObject -Class Win32_DiskDrive | ForEach-Object {$_.Signature}
	foreach ($signature in $signatures)
	{
		$disk = Get-WmiObject Win32_DiskDrive | Where {$_.Signature -eq $signature}
		$diskID = $disk.index
		$diskPartScript = @"
select disk $diskID
online disk noerr
"@
	$diskPartScript | diskpart | Out-Null	
	}
}

function SetDiskOnlineForAbove2012R2
{
	$offlineNumbers = Get-Disk | Where-Object {$_.OperationalStatus -eq "Offline"} | ForEach-Object {$_.Number}
	foreach($offlineNumber in $offlineNumbers)
	{
		Set-Disk -Number $offlineNumber -IsOffline $false
	}
}


# The main program

while ($true)
{
	Write-Host "######################################################################################"
	Write-Host "#               input the number and execute the module                              #"
	Write-Host "# 0. initialize the server just for new OS for your attention                        #" -ForegroundColor Red
	Write-Host "# 1. rename Administrator to zyadmin，update the description to Account for zhuyun   #"
	Write-Host "# 2. set random password for user and set the password never expires                 #"
	Write-Host "# 3. create new user and add the user to administrators' group                       #"
	Write-Host "# 4. enable remote desktop and update the port to 40022                              #"
	Write-Host "# 5. start and stop some service                                                     #"
	Write-Host "# 6. display sysinfo on desktop when join the domain for new OS                      #"
	Write-Host "# 7. rename the server's hostname                                                    #"
	Write-Host "# 8. reboot the server                                                               #"
	Write-Host "# 9. exit the script                                                                 #"
	Write-Host "######################################################################################"
	
	
	$inputNum = Read-Host "Please input the number that you want to execute the module"
	switch ($inputNum)
	{
		{ $_ -eq "0" } {
			ChangeAdminName -adminName "$newAdmin"
			ChangeComment -commInfo $commentInfo
			SetPwdAndNoExpires -needSetPwdAccount "$newAdmin"
			
			# input the new user 

			while ($true)
			{
				$newUser = Read-Host "Please input the new admin user or input 'no' to exit this step"
				if($newUser.ToLower() -eq "no")
				{
					break;
				}
				else
				{
					if (Get-WmiObject -Class Win32_UserAccount -Filter "Name='$newUser'")
					{
						Write-Host -ForegroundColor Red "The user already exists, please input another user"
					}
					else
					{
						break;
					}
				}
			}
			if($newUser -ne "no")
			{
				CreateUserAndAddToGroup -newUser $newUser
				SetPwdAndNoExpires -needSetPwdAccount $newUser
			}
			# enable remote desktop
			$kernalVersion = (Get-WmiObject -Class Win32_OperatingSystem).version
			switch ($kernalVersion)
			{
				{ $kernalVersion -match "6.1" }{ EnableRdp; SetDiskOnlineFor2008R2; break; }
				{ $kernalVersion -match "6.3" }{ EnableRdp; DisUserAuthRequired; SetDiskOnlineForAbove2012R2; break; }
				{ $kernalVersion -match "10.0" }{ EnableRdp; DisUserAuthRequired; SetDiskOnlineForAbove2012R2; break; }
			}
			
			# modify the port to 40022 for remote desktop
			ChangeRdpPort;
			
			# change some values for group policy and regedit
			ChangeGroupPolicyAndRegedit
			
			# disable some services
			foreach ($disableService in $disableServices)
			{
				DisableService -disableServiceName "$disableService"
			}
			# enable some services
			foreach ($enableService in $enableServices)
			{
				EnableService -enableServiceName "$enableService"
			}
			
			# input the new hostname which maximun characters number is 15
			while ($true)
			{
				$newHostname = Read-Host "Please input the new hostname"
				if ($newHostname.Length -gt 15)
				{
					Write-Host -ForegroundColor Red "Please input another hostname because your character numbers is greater than 15"
					continue;
				}
				else
				{
					break;
				}
			}
			# rename the hostname
			ChangeHostname -newName "$newHostname"

			$name = $newHostname
			$domain = Get-WmiObject -Class Win32_ComputerSystem | ForEach-Object {$_.Domain}
			$hostname = $domain + "\" + $name
			$ips = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -like ‘10.*’-or $_.IPAddress -like ‘172.*’-or $_.IPAddress -like ‘192.*’} | ForEach-Object {$_.IPAddress}
			if($ips.Count -gt 1){ $ip = $ips[0] }else{ $ip = $ips }
			$cpuinfo = Get-WmiObject -Class Win32_Processor | ForEach-Object {$_.Name}
			$memTotal = 0
			$mems = get-wmiobject -class "win32_physicalmemory" | ForEach-Object {$_.Capacity}
			foreach($mem in $mems){ $memTotal += $mem }
			$memTotal = $memTotal / 1GB
			AddTextToImage  -sourcePath "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -destPath "C:\Windows\Web\Wallpaper\Windows\new.jpg" -title "主机：$hostname" -description "地址：$ip" -cpu $cpuinfo -mem "内存：$memTotal GB"
			
if(-not (Test-Path C:\Windows\System32\WindowsPowerShell\v1.0\setwallpaper.PS1))
{ 
	New-Item C:\Windows\System32\WindowsPowerShell\v1.0\setwallpaper.PS1 -type file | Out-Null
	{	
		$setwallpapersource = @"
		using System.Runtime.InteropServices;
		public class wallpaper
		{
			public const int SetDesktopWallpaper = 20;
			public const int UpdateIniFile = 0x01;
			public const int SendWinIniChange = 0x02;
			[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
			private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
			public static void SetWallpaper ( string path )
			{
				SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
			}
		}
"@
		Add-Type -TypeDefinition $setwallpapersource
		[wallpaper]::SetWallpaper("C:\Windows\Web\Wallpaper\Windows\new.jpg")
	} | Out-File C:\Windows\System32\WindowsPowerShell\v1.0\setwallpaper.PS1
}
	
			# modify regedit to run setwallpaper.PS1 script when user login the system.
			$runpath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
			$runresult = Get-ItemProperty -Path $runpath
			if(-not ($runresult -match "setwallpaper"))
			{
				Set-ItemProperty -Path $runpath -Name setwallpaper -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\Windows\System32\WindowsPowerShell\v1.0\setwallpaper.PS1'
			}
			
			# input yes to reboot the server
			$YesOrNo = Read-Host "Please input 'yes' to reboot the server"
			if ($YesOrNo.ToLower() -eq "yes")
			{
				RebootServer
			}
			break;
		}
		{ $_ -eq "1" } { ChangeAdminName -adminName "$newAdmin"; ChangeComment -commInfo $commentInfo; break; }
		{ $_ -eq "2" } {
			while ($true)
			{
				$user = Read-Host "Please input the account you would modify it's password"
				if (-not (Get-WmiObject -Class Win32_UserAccount -Filter "Name='$user'"))
				{
					Write-Host -ForegroundColor Red "The account does not exists, please input the correct one."
					continue;
				}
				else
				{
					break;
				}
			}
			SetPwdAndNoExpires -needSetPwdAccount $user
			break;
		}
		{ $_ -eq "3" } {
			while ($true)
			{
				$newUser = Read-Host "Please input the new admin user"
				if (Get-WmiObject -Class Win32_UserAccount -Filter "Name='$newUser'")
				{
					Write-Host -ForegroundColor Red "The account already exists, please input another one."
					continue;
				}
				else
				{
					break;
				}
			}
			CreateUserAndAddToGroup -newUser $newUser
			break;
		}
		{ $_ -eq "4" } {
			# enable remote desktop
			$kernalVersion = (Get-WmiObject -Class Win32_OperatingSystem).version
			switch ($kernalVersion)
			{
				{ $kernalVersion -match "6.1" }{ EnableRdp; break; }
				{ $kernalVersion -match "6.3" }{ EnableRdp; DisUserAuthRequired; break; }
				{ $kernalVersion -match "10.0" }{ EnableRdp; DisUserAuthRequired; break; }
			}
			# modify the port to 40022 for remote desktop
			ChangeRdpPort;
			break;
		}
		{ $_ -eq "5" } {
			# disable some services
			foreach ($disableService in $disableServices)
			{
				DisableService -disableServiceName "$disableService"
			}
			# start some services
			foreach ($enableService in $enableServices)
			{
				EnableService -enableServiceName "$enableService"
			}
			break;
		}
		{ $_ -eq "6" } {
			# display sysinfo on desktop for new OS when join the domain
			
			$name = Get-WmiObject -Class Win32_ComputerSystem | ForEach-Object {$_.Name}
			$domain = Get-WmiObject -Class Win32_ComputerSystem | ForEach-Object {$_.Domain}
			$hostname = $domain + "\" + $name
			$ips = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -like ‘10.*’-or $_.IPAddress -like ‘172.*’-or $_.IPAddress -like ‘192.*’} | ForEach-Object {$_.IPAddress}
			if($ips.Count -gt 1){ $ip = $ips[0] }else{ $ip = $ips }
			$cpuinfo = Get-WmiObject -Class Win32_Processor | ForEach-Object {$_.Name}
			$memTotal = 0
			$mems = get-wmiobject -class "win32_physicalmemory" | ForEach-Object {$_.Capacity}
			foreach($mem in $mems){ $memTotal += $mem }
			$memTotal = $memTotal / 1GB
			AddTextToImage  -sourcePath "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -destPath "C:\Windows\Web\Wallpaper\Windows\new.jpg" -title "主机：$hostname" -description "地址：$ip" -cpu $cpuinfo -mem "内存：$memTotal GB"

			#logoff the system
			$logoff = Read-Host "Please input 'yes' to logoff the system"
			if($logoff.ToLower() -eq "yes")
			{ 
				logoff.exe
			}
			break;
		}
		{ $_ -eq "7" } {
			# input the new hostname which maximun characters number is 15
			while ($true)
			{
				$newHostname = Read-Host "Please input the new hostname"
				if ($newHostname.Length -gt 15)
				{
					Write-Host -ForegroundColor Red "Please input another hostname because your character numbers is greater than 15"
					continue;
				}
				else
				{
					break;
				}
			}
			# rename the hostname
			ChangeHostname -newName "$newHostname"
			break;
		}
		{ $_ -eq "8" } {
			$YesOrNo = Read-Host "Please input 'yes' to reboot the server"
			if ($YesOrNo.ToLower() -eq "yes")
			{
				RebootServer
			}
			break;
		}
		{ $_ -eq "9" } { exit; }
	}
}