##########################################################
##                                                      ##
##  Authenticates with Microsoft Graph as an admin.     ##
##  Defines the sender and recipient email addresses.   ##
##  Defines the phishing email subject, body, and URL.  ##
##  Sends the phishing email.                           ##
##  Disconnects from Microsoft Graph.                   ##
##                                                      ##
##########################################################

# Authenticate with Microsoft Graph
Connect-MgGraph

# Define the sender and recipient email addresses
$senderAddress = "external@example.com" # Replace this with the sender's email address
$recipientAddress = "user@example.com" # Replace this with the recipient's email address

# Define the phishing email subject, body, and URL
$subject = "Important: Reset Your Password"
$body = @"
<html>
  <body>
    <p>Dear user,</p>
    <p>We have detected unusual activity on your account. Please reset your password by clicking the link below:</p>
    <p><a href="http://phishing.example.com/reset-password">Reset your password</a></p>
    <p>Thank you for your attention.</p>
    <p>IT Support Team</p>
  </body>
</html>
"@

# Send the phishing email
Send-MgMail -From $senderAddress -To $recipientAddress -Subject $subject -Body $body -BodyContentType 'html'
Write-Host "Phishing email sent to: $recipientAddress"

# Disconnect from Microsoft Graph
Disconnect-MgGraph
