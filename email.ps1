# Email configuration for Gmail
# Replace "senders_mail" with your email
# Replace "mail_to_recieve_alerts" with the mail you want to use for recieving alerts
# Replace "mail_to_send_alerts" with the mail you want to use to send alerts
# Insert the application code (Example:x3wa stgl szmf bu1t) for the mail you want to use alerts in "smtpPassword"
# Incase you are not clear, check the "email copy.ps1" file for an example

$smtpServer = "smtp.gmail.com"
$smtpFrom = "<senders_mail>"
$smtpTo = "<mail_to_recieve_alerts>"
$smtpSubject = "File Integrity Monitoring Report"
$smtpBody = "Changes have been detected in the baseline. Review the details in the attached report."

# Gmail SMTP credentials
$smtpUsername = "<mail_to_send_alerts>"
$smtpPassword = "<send_mail_application_code>"  # Replace with your generated App Password

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
