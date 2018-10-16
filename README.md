# XboxStreamingFix
Takes care of Windows 10 + Hyper-V + Docker messing up Xbox app streaming and auto discovery

## Background

I have a Windows computer that has 2 physical network adapters, 1 wired, 1 wireless. 
I also have a veritable collection of software packages installed due to being a software developer.

The big one here is Hyper-V and Docker. This will create a number of virtual network adapters on your machine. All this is fine and good and normal for computery things. Where stuff gets all pooched up is in the Xbox App.

## Issues

1. Autodiscovery not working
1. Remote wake up not working
1. Streaming unable to connect

## What the script does

*As with all things that come from the internet, please review the script, if it messes up your setup. I'm sorry, but it's at your own risk.*

From a lot of trial and error it appears that there is a service the xbox app uses to do all it's network things. So disabling all the stuff that can confuse it, then restarting seems to do the trick

`Initialize-XboxStreamingFix` does 

```
Stop-DockerServices
Stop-HyperVServices
Disable-HyperVNetworkDevices
Restart-XboxServices
```

All the above commands are part of the script package, nothing is coming from an external dependency here.

## Puting everything back

`Undo-XboxStreamingFix` will run the above in reverse (short of restarting the xbox services)

If your machine restarts before you undo the changes that's ok. The services autostart state isn't manipulated, when docker and hyper-v start back up they will recreate/re-enable the networking devices. 
