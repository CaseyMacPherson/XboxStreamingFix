$stoppedServicesState = "$env:TEMP\services_disabled"
$disabledDevicesState = "$env:TEMP\devices_disabled"

if ($PSVersionTable.PSVersion.Major -ne 5) {
    Write-Host "This script is only designed to work with Powershell Version 5"
    exit 1;
}

function Stop-Services {
    param([Array]$ServicesToDisable)
    
    foreach ($service in $servicesToDisable) {
        Add-Content -Path $stoppedServicesState -Force $service.Name
        Write-Host "Stopping Service: " $service.DisplayName
        Stop-Service -Force -Name $service.Name -Confirm:$false
    }
}

function Get-RunningService {
    param([string]$DisplayNameMatch)
    Get-Service | Where-Object { $_.DisplayName -Match $DisplayNameMatch -and $_.Status -eq "Running" }
}

function Stop-HyperVServices {
    $servicesToDisable=Get-RunningService "Hyper-V"   
    Stop-Services $servicesToDisable
}

function Stop-DockerServices {
    $servicesToDisable=Get-RunningService "Docker"
    Stop-Services $servicesToDisable
}

function Start-Services {
    if(-not [System.IO.File]::Exists($stoppedServicesState)) {
        Write-Host "services_disabled file isn't present. Can't determine what to start"
        return
    }

    $previouslyStoppedServices=Get-Content $stoppedServicesState
    
    foreach ($stoppedService in $previouslyStoppedServices) {
        $instance = Get-Service -Name $stoppedService
        if($instance.Status -eq "Stopped") {
            Write-Host "Starting Service:" $instance
            Start-Service $instance
        } else {
            Write-Host "Service: $instance is already running"
        }
    }

    Write-Host "Removing temporary file $stoppedServicesState"
    Remove-Item $stoppedServicesState
}

<#
.SYNOPSIS
Disables Hyper-V virtual Network adapters

.DESCRIPTION
Windows 10 Xbox app is easily confused by multiple network adapters that get created by Hyper-V.
This will disable the Pnp Devices associated with them. It will record the devices it disables.
See Enable-HyperVNetworkDevices

.EXAMPLE
Disable-HyperVNetworkDevices

#>
function Disable-HyperVNetworkDevices {
    $devicesToDisable=Get-PnpDevice | Where-Object {
                        $_.FriendlyName -Match "Hyper-V" -and 
                        $_.Class -eq "Net" -and 
                        $_.Status -eq "Ok"
                    }

    foreach($device in $devicesToDisable) {
        Add-Content -Path $disabledDevicesState -Force $device.InstanceId

        #Have not figured out a way around this confirmation requirement here
        Write-Host "Disabling " $device.FriendlyName
        Disable-PnpDevice -InputObject $device -Confirm:$false
    }
}

<#
.SYNOPSIS
Enables previously Disabled Hyper-V networking devices

.DESCRIPTION
Windows 10 Xbox app gets easily confused by multiple networking devices that get created
with Hyper-V.

.EXAMPLE
Enable-HyperVNetworkDevices

.NOTES
General notes
#>#
function Enable-HyperVNetworkDevices {
    $devicesToEnable = Get-Content $disabledDevicesState

    foreach($device in $devicesToEnable) {
        $deviceInstance = Get-PnpDevice -InstanceId $device

        if($deviceInstance.Status -eq "Error") {
            Write-Host "Enabling " $deviceInstance.FriendlyName " DeviceId: " $deviceInstance.DeviceId

            #This cmdlet requires confirmation from the end user. I have not found a way around in a pure powershell fashion
            Enable-PnpDevice -InstanceId $deviceInstance.InstanceId -Confirm:$false
        } else {
            Write-Host "Device: " $deviceInstance.FriendlyName " is already enabled"
        }
    }

    Remove-Item $disabledDevicesState
}

<#
.SYNOPSIS
Restart running Xbox services

.DESCRIPTION
This must be run after disabling all of the virtual network devices that are related
to Hyper-V. The reason for this, is there is some apparent issue with the Xbox app
where it is unable to handle autodiscovery or streaming of your Xbox when there are virtual
ethernet adapters.

.EXAMPLE
Restart-XboxServices

.NOTES
Restarts anything that's currently in a Running state
#>
function Restart-XboxServices {
    Get-Service | Where-Object {
        $_.DisplayName -Match "Xbox" -and 
        $_.Status -eq "Running" } | 
        ForEach-Object{ Restart-Service -Force $_ }
}

<#
.SYNOPSIS
Sets up XboxStreaming for development machines

.DESCRIPTION
Takes care of shutting down services and disabling virtual hardware devices
that interfere with the Xbox application.

The script takes note of which devices and services it stops. Run Undo-XboxStream to reverse
the changes

.EXAMPLE
Initialize-XboxStreamingFix
#>
function Initialize-XboxStreamingFix {
    Stop-DockerServices
    Stop-HyperVServices
    Disable-HyperVNetworkDevices
    Restart-XboxServices
}

<#
.SYNOPSIS
Reverses changes needed to make Xbox Streaming work

.DESCRIPTION
Will restore Hyper-V and Docker services to their prior state

.EXAMPLE
Undo-XboxStreamingFix
#>
function Undo-XboxStreamingFix {
    Enable-HyperVNetworkDevices
    Start-Services
}
