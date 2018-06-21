while($true)
{
	$date = Get-Date -Format yyyy-MM-dd
	$file = "C:\Users\Administrator\SetAsAService\"+ $date + ".log"
	Robocopy.exe C:\source E:\destination /E /XO /SL /LOG+:$file
	Start-Sleep 1
}