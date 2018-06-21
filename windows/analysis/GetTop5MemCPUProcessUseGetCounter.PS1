<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 11:15
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	GetTop5MemCPUProcessUseGetCounter
	===========================================================================
	.DESCRIPTION
		Get Top 5 process for CPU and Mem.
#>

$ErrorActionPreference = "SilentlyContinue"
Write-Host "`t"
Write-Host -ForegroundColor Green  "Please be patient with the output ......"
Write-Host "`t"
Write-Host "`t"
Write-Host -ForegroundColor Green  "The top 5 Mem process as below:"

$processMem = Get-Counter "\Process(*)\Working Set - Private"
$memoutputs = $processMem.CounterSamples | Select-Object @{ "Label" = "ProcessMemName"; "Expression" = { (($_.Path).split(")\"))[3].SubString(8) } }, @{ "Label" = "ProcessMem(MB)"; "Expression" = { "{0,8}" -f ("{0:N}" -f ($_.CookedValue/1MB)) } } | Sort-Object "ProcessMem(MB)" -Descending | ?{ $_.ProcessMemName -ne "_total" } | Select-Object -First 5
foreach ($memoutput in $memoutputs)
{
	$name = $memoutput.ProcessMemName
	$id = (Get-Counter "\Process($name)\ID Process").CounterSamples | ForEach-Object { $_.CookedValue }
	$memoutput | Add-Member -Name PID -Value $id -MemberType NoteProperty
}

$memoutputs | Out-String

Write-Host -ForegroundColor Green  "The top 5 CPU process as below:"

$cpuCores = (Get-WmiObject -Class Win32_ComputerSystem).NumberOfLogicalProcessors
$processCpu = Get-Counter '\Process(*)\% Processor Time'
$cpuoutputs = $processCpu.CounterSamples | Select-Object @{ "Label" = "ProcessCpuName"; "Expression" = { (($_.Path).split(")\"))[3].SubString(8) } }, @{ "Label" = "ProcessCPU(%)"; "Expression" = { "{0,6}" -f ("{0:f}" -f ($_.CookedValue/$cpuCores)) } } | Sort-Object -Property "ProcessCPU(%)" -Descending | ?{ $_.ProcessCpuName -ne "_total" } | Select-Object -First 5
foreach ($cpuoutput in $cpuoutputs)
{
	$name = $cpuoutput.ProcessCpuName
	$id = (Get-Counter "\Process($name)\ID Process").CounterSamples | ForEach-Object { $_.CookedValue }
	$cpuoutput | Add-Member -Name PID -Value $id -MemberType NoteProperty
}

$cpuoutputs | Out-String

Write-Host "You can close the window directly."
[Console]::ReadKey()