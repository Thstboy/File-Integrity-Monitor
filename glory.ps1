# Import the email module
Import-Module "C:\Users\addis\Documents\PROJECT\Re-Implementation\Real Thing\email.ps1"

# Baseline file path
$baselineFilePath = "C:\Users\addis\Documents\PROJECT\Re-Implementation\Real Thing\basel1nes.csv"

# Load necessary assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Load XAML file
$xamlFile = "C:\Users\addis\Documents\PROJECT\A new story\MainWindow.xaml"
$inputXAML = Get-Content -Path $xamlFile -Raw
$inputXAML = $inputXAML -replace 'mc:Ignorable="d"', '' -replace "x:N","N" -replace "^<Win.*","<Window"
[xml]$XAML = $inputXAML

# Create a form from XAML
$reader = New-Object System.Xml.XmlNodeReader $XAML
try {
    $psform = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    Write-Host "Error loading XAML: $_"
    throw
}

# Set variables for named elements in XAML
$XAML.SelectNodes("//*[@Name]") | ForEach-Object {
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $psform.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}

# Function to get baseline
function Get-Baseline {
    $baselineFilePath = $var_bl.Content
    $baselineFileContents = Import-Csv -Path $baselineFilePath -Delimiter ','
    foreach ($file in $baselineFileContents) {
        $var_ListFiles.Items.Add("$($file.path)")
    }
}

# Button click event to select baseline
$var_SelectBaseline.Add_Click({
    $var_ListFiles.Items.Clear()
    $inputFilePick = New-Object System.Windows.Forms.OpenFileDialog
    $inputFilePick.Filter = "CSV (*.csv) | *.csv"
    $inputFilePick.ShowDialog()
    $baselineFilePath = $inputFilePick.FileName

    if (Test-Path -Path $baselineFilePath) {
        if (($baselineFilePath.Substring($baselineFilePath.Length-4,4)) -eq ".csv"){
            $var_bl.Content=$baselineFilePath
            Get-Baseline
        }else {
            $var_bl.Content="Invalid file Selected. Select a .csv file"
        }
    }
})

# Button click event to add files to baseline
$var_AddFiles.Add_Click({
    $var_ListFiles.Items.Clear()
    $inputFilePick = New-Object System.Windows.Forms.OpenFileDialog
    $inputFilePick.ShowDialog()
    $baselineFilePath = $var_bl.Content
    $targetFilePath = $inputFilePick.FileName

    $currentBaseline = Import-Csv -Path $baselineFilePath -Delimiter ","

    $existingFile = $currentBaseline | Where-Object path -eq $targetFilePath

    if ($existingFile) {
        $confirmation = [System.Windows.Forms.MessageBox]::Show(
            "The file '$targetFilePath' already exists in the baseline. Do you want to overwrite it?",
            "Overwrite Confirmation",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($confirmation -eq [System.Windows.Forms.DialogResult]::Yes) {
            $hash = Get-FileHash -Path $targetFilePath
            $existingFile.hash = $hash.hash
            $currentBaseline | Export-Csv -Path $baselineFilePath -Delimiter ',' -NoTypeInformation
            $var_ListFiles.Items.Add("$targetFilePath has been updated in the baseline.")
        } else {
            $var_ListFiles.Items.Add("$targetFilePath was not added to the baseline.")
        }
    } else {
        $hash = Get-FileHash -Path $targetFilePath
`       Add-Content -Path $baselineFilePath -Value "$targetFilePath,$($hash.hash)"
        #$hash = Get-FileHash -Path $targetFilePath
        #"$targetFilePath,$($hash.hash)" | Out-File -FilePath $baselineFilePath -Append -Encoding ASCII
        $var_ListFiles.Items.Add("$targetFilePath has been added to the baseline.")
    }

    Get-Baseline
})


# Button click event to play and check for changes
$var_Play.Add_Click({
    $var_ListFiles.Items.Clear()
    $baselineFilePath = $var_bl.Content
    $baselineContents = Import-Csv -Path $baselineFilePath -Delimiter ','

    # Initialize the $changesDetected variable
    $changesDetected = $false
    $changedFiles = @()  # Array to store changed files

    foreach ($file in $baselineContents) {
        if (-not [string]::IsNullOrEmpty($file.path)) {
            if (Test-Path -Path $file.path) {
                $currentHash = Get-FileHash -Path $file.path
                if ($currentHash.hash -eq $file.hash) {
                    $var_ListFiles.Items.Add("$($file.path) has not changed")
                } else {
                    $var_ListFiles.Items.Add("$($file.path) has changed")
                    $changesDetected = $true
                    $changedFiles += $file.path  # Add changed file to the array
                }
            } else {
                $var_ListFiles.Items.Add("$($file.path) is not found!")
                $changesDetected = $true
            }
        }
    }
    
    # Check if any changes were detected
    if ($changesDetected) {
        # Send email notification with details of changed files
        $changedFilesText = $changedFiles -join "`r`n"
        $emailBody = "Changes have been detected in the baseline. Review the details in the attached report in this file.`r`n`r`nFile Path:`r`n$changedFilesText"
        
        Send-Email -smtpServer $smtpServer -smtpFrom $smtpFrom -smtpTo $smtpTo -smtpSubject $smtpSubject -smtpBody $emailBody -smtpUsername $smtpUsername -smtpPassword $smtpPassword
        $var_ListFiles.Items.Add("Email sent successfully")
    } else {
        $var_ListFiles.Items.Add("No changes detected.")
    }
})



# Button click event to create a new baseline
$var_newBaseline.Add_Click({
    $var_ListFiles.Items.Clear()
    $inputFilePick = New-Object System.Windows.Forms.SaveFileDialog
    $inputFilePick.Filter = "CSV (*.csv) | *.csv"
    $inputFilePick.ShowDialog()
    $baselineFilePath = $inputFilePick.FileName
    "path,hash" | Out-File -FilePath $baselineFilePath -Force
    $var_bl.Content = $baselineFilePath
    Get-Baseline
})

# Show the form
$psform.ShowDialog()
