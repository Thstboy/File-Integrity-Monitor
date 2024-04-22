# Email configuration for Gmail
$smtpServer = "smtp.gmail.com"
$smtpFrom = "oritsegbemiprosper@gmail.com"
$smtpTo = "oritsegbemi.m1802087@st.futminna.edu.ng"
$smtpSubject = "File Integrity Monitoring Report"
$smtpBody = "Changes have been detected in the baseline. Review the details in the attached report."

# Gmail SMTP credentials
$smtpUsername = "oritsegbemiprosper@gmail.com"
$smtpPassword = "yewi hygl szmf buit"  # Replace with your generated App Password

# Function to send email using SmtpClient
function Send-Email {
    param (
        [string]$smtpServer,
        [string]$smtpFrom,
        [string]$smtpTo,
        [string]$smtpSubject,
        [string]$smtpBody,
        [string]$smtpUsername,
        [string]$smtpPassword
    )

    # Create SmtpClient object
    $smtpClient = New-Object Net.Mail.SmtpClient
    $smtpClient.Host = $smtpServer
    $smtpClient.Port = 587  # Use the appropriate port (587 for Gmail)
    $smtpClient.EnableSsl = $true  # This enables SSL
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Set the credentials
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential -ArgumentList $smtpUsername, $smtpPassword

    # Create MailMessage object
    $mailMessage = New-Object Net.Mail.MailMessage
    $mailMessage.From = $smtpFrom
    $mailMessage.To.Add($smtpTo)
    $mailMessage.Subject = $smtpSubject
    $mailMessage.Body = $smtpBody

    try {
        # Send email
        $smtpClient.Send($mailMessage)
        Write-Host "Email sent successfully."
    } catch {
        Write-Host "Error sending email: $_"
    }
}

# Example usage
Send-Email -smtpServer $smtpServer -smtpFrom $smtpFrom -smtpTo $smtpTo -smtpSubject $smtpSubject -smtpBody $smtpBody -smtpUsername $smtpUsername -smtpPassword $smtpPassword
