#
# Set-AllVMHostService.ps1
#

#$vCenter = 'vCenter01','vCenter02','vCenter03'
#$Action = 'Start'
#$VMHostService = 'SSH'

# This function will either stop or start a particular service on every host connected to your vCenter server(s).
Function Set-AllVMHostService
{
[CmdletBinding()]  
Param( 
        # The name of the VMHost service
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $VMHostService,
        # The action (Start or Stop)
        [Parameter(Mandatory=$true, 
                   Position=1)]
                   [ValidateSet("Start","Stop")]
        [string]$Action,
		# The vCenter(s) to connect to
        [Parameter(Mandatory=$true, 
                   Position=2)]
        [string[]]$vCenter
    )

	Begin
	{
		Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
		Set-PowerCLIConfiguration -InvalidCertificateAction 'Ignore' -DisplayDeprecationWarnings:$false -confirm:$false
		Connect-VIServer $vCenter
	}
	Process
	{
		switch ($Action)
		{
			# Finds all hosts where the service is stopped and starts the service
			Start
			{
				Get-VMHost | Get-VmHostService | Where-Object {$_.Label -eq "$VMHostService" -AND $_.Running -eq 'False'} | Start-VMHostService -Confirm:$False
			}
			
			# Finds all hosts where the service is running and stops the service
			Stop
			{
				Get-VMHost | Get-VmHostService | Where-Object { $_.Label -eq "$VMHostService" -AND $_.Running -eq 'True'} | Stop-VMHostService -Confirm:$False
			}
		}		
	}
	End
	{
		Disconnect-VIServer $vCenter -Confirm:$False
	}
}

Set-AllVMHostService -VMHostService $VMHostService -Action $Action -vCenter $vCenter
