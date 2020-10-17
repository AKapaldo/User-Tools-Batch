<#
.Synopsis
Used to install User Tools software on a remote machine.
.Description
Used to install User Tools software on the desktop of a remote machine.
.Parameter ComputerName
Set a remote machine name to place the software on.
.Parameter User
AD Username for functions
.Notes
To install this module, place the file in your c:\Users\<Username>\Documents\MicrosoftPowerShell\Modules\usertools\ folder. You will need to create these folders. They do not exist by default.
#>
Function Push-UserTools {
[cmdletbinding()]
param(
	[Parameter()]
	[string[]]$ComputerName=$(read-host -prompt "Enter Remote System Number"),
	[Parameter()]
	[string]$User=$(read-host -prompt "Enter AD Username")
	)
    # Pushes the User Command Tools batch file to the desktop of the user's computer
    

    Clear-Host
    $User = Invoke-Command -ComputerName $ComputerName -ScriptBlock {(Get-WMIObject -class Win32_ComputerSystem | select -expand username).split('\')}
	$User = $User[1]
	$Path = Get-ADUser -Identity $User -Properties HomeDirectory | select -expand HomeDirectory
    Write-Host "User Tools Batch File will be transferred to desktop of $ComputerName"
	Copy-Item -Path "c:\Userdata\Console.msc" -Destination "\\$ComputerName\c$\Userdata\Console.msc"
    Invoke-Command -Computer $ComputerName -ScriptBlock {

    Set-Content "C:\Users\$User\Desktop\User Tools.bat" @"
@echo off
:: User Tools 1.0
:Start
cls
title User Tools 1.0
c:
cd\
echo 1. Get I.P. Address
echo 2. Get Computer System Information
echo 3. Force Group Policy Update
echo 4. Map Z:\ Drive
echo 5. Check AD Password Expiration
echo 6. Clear Certificates
echo.
CHOICE /C 123456 /M "Enter your choice:" 
IF ERRORLEVEL 6 GOTO Certificates
IF ERRORLEVEL 5 GOTO PassExpiry
IF ERRORLEVEL 4 GOTO MapDrive
IF ERRORLEVEL 3 GOTO GPUpdate
IF ERRORLEVEL 2 GOTO SystemInfo
IF ERRORLEVEL 1 GOTO IPConfig
:IPConfig
cls
title I.P. Configuration
ipconfig|findstr /i /c:"Ethernet" /c:"Wireless" /c:"IPv4"
echo.
pause
GOTO Start
:SystemInfo
cls
title Computer System Information
systeminfo|findstr /i /c:"Host Name" /c:"OS Name" /c:"OS Version" /c:"Original Install Date" /c:"System Boot Time" /c:"System Up Time" /c:"System Manufacturer" /c:"System Model" /c:"System Type" /c:"Total Physical Memory"
echo.
pause
GOTO Start
:GPUpdate
cls
title Forcing Group Policy Update
echo n | klist -lh 0 -li 0x3e7 purge
echo n | gpupdate /force
echo Do NOT log out now!
echo n | klist -lh 0 -li 0x3e7 purge
echo n | gpupdate /force
echo Do NOT log out now!
cls
title Group Policy Update Complete
echo Group Policy Update Complete.
echo Please note that most changes will not take effect until you have rebooted.
echo It is strongly recommended that you reboot now.
echo.
pause
GOTO Start
:MapDrive
cls
title Map Z:\ Drive
echo Mapping Z:\ Drive
echo.
Net Use Z: $Path /Persistent:yes
title Z:\ Drive Mapped
echo Z:\ Drive Mapped
echo.
pause
GOTO Start
:PassExpiry
cls
title Check AD Password Expiration
Net User $User /Domain | findstr /i /c:"Password Expires"
echo.
pause
GOTO Start
:Certificates
cls
title Clear Certificates	
echo Opening Certificates Console
start c:\Userdata\Clear certificates.msc
echo Instructions:
echo Click on one of the certificates in the center panel.
echo Hold the control key and press A. This will select them all.
echo Press the delete key.
echo You will get a warning about not being able to decrypt encrypted data. Press Yes.
echo Close the window.
echo.
pause
GOTO Start
"@
    }
    
    Pause
}
