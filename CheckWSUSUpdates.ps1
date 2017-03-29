#########################################################################################################
#########################################################################################################
###########################PowerShell Script for checking WSUS Updates###################################
#######################Date: 24-01-2017 | Version: 1.0 | Author: Paul Witkamp############################
###############################ICT-Partners Groningen Netherlands########################################
#########################################################################################################

################################Load form library########################################################
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
#################################End form library #######################################################  

############################################## Start functions ##########################################
#This function checks wether AD modules are installed, if not a popup will show and the script stops
Function CheckAndRun{

    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        GetOUs
        $Form.Add_Shown({$Form.Activate()})
        [void] $Form.ShowDialog()
    }
    Else{
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $MessageBox1 = [System.Windows.Forms.Messagebox]::Show("AD Module Not Installed","Warning",0,
        [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
}

#Get all OUs in the domain and put them in dropbox list
Function GetOUs{

    $OUs = Get-ADOrganizationalUnit -Filter * -Properties Name
            
        Foreach($OU In $OUS)
        {
             $DropDown.Items.Add($OU) | out-null      
        }
}

function CreateTempFile{
    
    $Global:SelectedGroup=$DropDown.SelectedItem.ToString()
    $GroupResult = Get-ADComputer -SearchBase $Global:SelectedGroup -Filter 'ObjectClass -eq "Computer"' | Select -Expand DNSHostName    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $OUName = $Global:SelectedGroup.Substring(0, $Global:SelectedGroup.IndexOf(','))
    $Date = Get-Date -Format "HH.mm d.MMM.yyyy"
    $UpdateReport = New-Item $DesktopPath\WSUSReport-$OUName-$Date.txt -ItemType file
    $Days = $SetDays.Text
   
    
       ForEach($Computer In $GroupResult)
        {
            $i++
            Add-Content $UpdateReport -Value $Computer
            Try{
             $Updates = Get-HotFix -ComputerName $Computer | where InstalledOn -gt ((Get-Date).Adddays(-$Days)) | Out-String
             Add-Content $UpdateReport $Updates
            }
                Catch{
                    $_ | Add-Content $UpdateReport
                }
            Write-Progress -Activity "Finding Updates" -Status "Percentage found:" -PercentComplete (($i / $GroupResult.length)  * 100) 
        }
    $Message=[System.Windows.Forms.Messagebox]::Show("Output created on the Desktop")
} 

############################################## end functions ##############################################

############################################# Start Form Build ############################################
#Setup form layout
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Check WSUS updates"
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$Form.Icon = $Icon
$Form.Size = New-Object System.Drawing.Size(900,170)
$Form.Opacity = 0.9
$Form.StartPosition = "CenterScreen"
$Form.Font = New-Object System.Drawing.Font("Times New Roman",10,[System.Drawing.FontStyle]::Italic)
############################################## Stop Form Build ############################################

############################################## Start box Build ############################################
#Create all controls on the form
$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = New-Object System.Drawing.Size(120,50)
$DropDown.Size = New-Object System.Drawing.Size(500,10)

$GroupLabel = New-Object System.Windows.Forms.Label
$GroupLabel.Location = New-Object System.Drawing.Size(70,52)
$GroupLabel.Text = "OU:"

$SetDays = new-object System.Windows.Forms.TextBox
$SetDays.Location = New-Object System.Drawing.Size(120,80)
$SetDays.Size = New-Object System.Drawing.Size(50,10)

$DayLabel = New-Object System.Windows.Forms.Label
$DayLabel.Location = New-Object System.Drawing.Size(70,85)
$DayLabel.Text = "Days:"

$Form.Controls.Add($DropDown)
$Form.Controls.Add($SetDays)
$Form.Controls.Add($GroupLabel)
$Form.Controls.Add($DayLabel)

############################################## Start buttons ###############################################
#Create all buttons on the form
$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(650,35) 
$Button.Size = New-Object System.Drawing.Size(100,40) 
$Button.Text = "Check" 
$Button.Add_Click({CreateTempFile}) 
$Form.Controls.Add($Button)

$CloseButton = New-Object System.Windows.Forms.Button 
$CloseButton.Location = New-Object System.Drawing.Size(750,35) 
$CloseButton.Size = New-Object System.Drawing.Size(100,40) 
$CloseButton.Text = "Exit" 
$CloseButton.Add_Click({$Form.Close()}) 
$Form.Controls.Add($CloseButton)  

############################################## end buttons ##################################################
#Run the script
CheckAndRun 
