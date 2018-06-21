<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2017 v5.4.142
	 Created on:   	2018/2/9 11:26
	 Created by:   	LiuYongjun
	 Organization: 	
	 Filename:     	TestPortIsConnected
	===========================================================================
	.DESCRIPTION
		The function is that test the port of an address whether is connected or not. For example, TestPortIsConnected 192.168.1.100 80
#>

$ip = $args[0]
$port = $args[1]

try
{
	#实例化一个TcpClient对象
	$tcpClient = New-Object Net.Sockets.TcpClient
	
	#如果连接成功，则$tcpClient.Connected的值为True
	$beginConn = $tcpClient.Connect($ip, $port)
	
	if ($tcpClient.Connected)
	{
		#关闭连接
		$tcpClient.Close()
		Write-Host -ForegroundColor Green "The port $port of $ip is connected."
	}
}
catch [System.Management.Automation.MethodInvocationException]
{
	$tcpClient.Close()
	Write-Host -ForegroundColor Red "The port $port of $ip is blocked."
}