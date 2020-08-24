#########################################################################
#																		#
#	Script Title: Repair-Service										#
#	Author: Brennan Custard												#
#	Date: 8/21/2020														#
#	Description: This script determines the status of a given 			#
#	Windows Service, makes attempts to get it running, and reports 		#
#	back with simple results suitable for monitoring/ticketing.			#
#																		#
#########################################################################

#Capture the name of the service we want to work on
$targetService = $args[0]

#Confirm that the service does in fact exist, try the specific service name first
try {
		$testSvc = Get-Service -Name $targetService -ErrorAction Stop
	}
	#Try the friendly name next
	catch [System.IO.IOException] {
			$testSvc = Get-Service -DisplayName $targetService -ErrorAction Stop
		}
			#Output NOEXIST and exit if the service passed to us doesn't exist
			catch{
				write-output NOEXIST
				exit
				}

#Now that we've confirmed our variable work with the running status
IF ($testSvc.status -eq "Running")
	{
		try
			{
				$svcRestart = Restart-Service -name $targetService -ErrorAction Stop
			}
			catch [System.IO.IOException]
				{
					$svcRestart = Restart-Service -DisplayName $targetService -ErrorAction Stop
				}
				catch
					{
						write-output RESTARTFAIL
						exit
					}
		write-output RESTARTED
		exit
	}

IF ($testSvc.status -eq "Stopped")
	{
		try
			{
				$svcRestart = Start-Service -name $targetService -ErrorAction Stop
			}
			catch [System.IO.IOException]
				{
					$svcRestart = Start-Service -DisplayName $targetService -ErrorAction Stop
				}
			
				catch
					{
						write-output CANTSTART
						exit
					}
		write-output STARTED
		exit
	}
#If its not running or stopped then its starting or stopping and we don't want to mess with it
write-output SVCBUSY

