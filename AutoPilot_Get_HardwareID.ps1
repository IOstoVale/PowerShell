#Created by Paul Witkamp on 14-01-2020. Info: info@witkamp-consultancy.nl
#
#Click OOBE until you can connect to WiFi, after connection is made go to the next step.
#During OOBE click SHIFT-F10, this will open a command window.
#Type PowerShell, this will switch to powershell context in the same window.
#Set Executionpolicy to unrestricted, after boot this setting will be back to normal. To do this enter this command:
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#
#Execute the script by typing AutoPilot_Get_HardwareID.ps1

#A new directory is created, this directory is used to save the downloaded script and as working location for the
#CSV files.
md c:\scripts
#The AutoPilotInfo script is downloaded from NuGet, URL: https://www.nuget.org/packages/Get-WindowsAutoPilotInfo/
#You have to approve this by clicking on yes.
Save-Script -Name Get-WindowsAutoPilotInfo -Path c:\scripts
#This variable is used to save the initial output of the Get-WindowsAutoPilotInfo script.
$TempCSV = "c:\scripts\TempCSV.csv"
#The Get-WindowsAutoPilotInfo script runs and saves the hardware info in the TempCSV file
c:\scripts\Get-WindowsAutoPilotInfo.ps1 -OutputFile $TempCSV

#It is recommended to use group tags in Autopilot, enter the device type you are using. This type
#will be the group tag for Autopilot.
$Server = Read-Host -Prompt 'Enter HW type: Laptop, Desktop, Test or VM?'
#This variable is used for the added group tag information
$OutPutCSV = "c:\scripts\$env:computername.csv"
#This routine adds a colum to the csv file with the name Group Tag and adds the group tag value
#typed in by the user in the previous step.
Import-Csv -Path $TempCSV | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name Group Tag -Value $Server -PassThru

} | Export-CSV $OutPutCSV

#Remove the temp csv file
Remove-Item $TempCSV

#When PowerShell edits a CSV file it adds a header into the file, Autopilot does not recognize this header
#and produces an error message, so the headers needs to be deleted.
(Get-Content -Path $OutPutCSV) |
    Where-Object { $_ -notlike '*#TYPE*' } |
    Set-Content -Path $OutPutCSV

#The last step is to copy the CSV file to the USB stick, first the USB driveletter must be recognized.
$USBLetter = (Get-WmiObject Win32_Volume -Filter "DriveType='2'").DriveLetter.Substring(0,1)
#The USB pad is set to a variable
$USBPath = $USBLetter+":\CSVFiles"
#The USB path is created
md $USBPath
#The CSV file is copied to the USB path
Copy-Item $OutPutCSV $USBPath
