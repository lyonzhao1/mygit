<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/8 18:00
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	ModifyInboundFirewallRules
	===========================================================================
	.DESCRIPTION
		Modify system default firewall rules.
#>

# export the system default firewall rules

function ExportDefaultRules
{
	$exportResult = netsh advfirewall export C:\defaultfirewall.pol
	if ($exportResult[0] -match "文件已存在" -or $exportResult[0] -match "file already exists")
	{
		Write-Host -ForegroundColor Red "The file already exists, please delete or rename it."
	}
	elseif ($exportResult[0] -match "确定" -or $exportResult[0] -match "Ok")
	{
		Write-Host -ForegroundColor Green "Export the system default firewall rules successfully，which located in C:\"
	}
	else
	{
		Write-Host -ForegroundColor Red "Failed to export the system default firewall rules, please check the cause."
	}
}

# disable all inbound firewall rules

function DisableInboundRules
{
	$disableInRules = netsh advfirewall firewall set rule name=all dir=in new enable=no
	$inRulesInfo = netsh advfirewall firewall show rule name=all dir=in status=enabled
	if ($inRulesInfo[1] -match "没有与指定标准相匹配的规则" -or $inRulesInfo[1] -match "No rules match")
	{
		Write-Host -ForegroundColor Green "All inbound firewall rules has been disabled successfully."
	}
	else
	{
		Write-Host -ForegroundColor Red "Some inbound firewall rules has not been disabled, please check."
		exit;
	}
}

# add inbound firewall rules（please make sure that the name of the firewall rule is unique）

function AddRulesForInbound
{
	param ($name,
		$protocal,
		$port)
	$addRuleInfo = netsh advfirewall firewall add rule name="$name" dir=in protocol="$protocal" localport="$port" action=allow enable=yes
	if ($addRuleInfo[0] -match "确定" -or $addRuleInfo[0] -match "Ok")
	{
		Write-Host -ForegroundColor Green "The firewall rule, which name is $name ，which protocal is $protocal, which port is $port has been added successfully."
	}
	else
	{
		Write-Host -ForegroundColor Red "The firewall rule failesto add."
	}
}


# delete inbound firewall rules

function DelRulesForInbound
{
	param ($name)
	
	$delRuleInfo = netsh advfirewall firewall delete rule name="$name"
	if ($delRuleInfo[1] -match "已删除 1 规则" -or $delRuleInfo[1] -match "Deleted")
	{
		Write-Host -ForegroundColor Green "The firewall rule, which name is $name ，which protocal is $protocal, which port is $port has been deleted."
	}
	else
	{
		Write-Host -ForegroundColor Red "Failed to delete the firewall rule, please check the cause."
	}
}


##################################################################################################################
#
#		The main program
#
##################################################################################################################

while ($true)
{
	Write-Host "##################################################################"
	Write-Host "#        input the number you want to execute the module         #"
	Write-Host "# 1. export the system default firewall rules                    #"
	Write-Host "# 2. disable all system default inbound firewall rules           #"
	Write-Host "# 3. add inbound firewall rules which you want defined           #"
	Write-Host "# 4. delete the firewall rules you specified                     #"
	Write-Host "# 5. exit the script                                             #"
	Write-Host "##################################################################"
	
	
	$inputNum = Read-Host "Please input the number you want to execute the module"
	switch ($inputNum)
	{
		{ $_ -eq "1" }{ ExportDefaultRules; break; }
		{ $_ -eq "2" }{ DisableInboundRules; break; }
		{ $_ -eq "3" }{
			while ($true)
			{
				$name = Read-Host "input the firewall name you will add"
				$nameInfo = netsh advfirewall firewall show rule name="$name"
				if (-not ($nameInfo[1] -match "没有与指定标准相匹配的规则" -or $nameInfo[1] -match "No rules match"))
				{
					Write-Host -ForegroundColor Red "The firewall name already exsits, please input again."
				}
				else
				{
					break;
				}
			}
			
			$protocal = Read-Host "input the protocal, TCP or UDP"
			$port = Read-Host "input the port"
			
			AddRulesForInbound -name $name -protocal $protocal -port $port
			break;
		}
		{ $_ -eq "4" }{
			while ($true)
			{
				$name = Read-Host "input the firewall rule's name which you will delete"
				$nameInfo = netsh advfirewall firewall show rule name="$name"
				if ($nameInfo[1] -match "没有与指定标准相匹配的规则" -or $nameInfo[1] -match "No rules match")
				{
					Write-Host -ForegroundColor Red "the name you input doesn't exsit, or is wrong, please input the correct one."
				}
				else
				{
					break;
				}
			}
			DelRulesForInbound -name $name
			break;
		}
		{ $_ -eq "5" }{ exit; }
	}
	
}