# Title: Active Directory Bulk User Creator
# Copyright (c) 2024 Magdy Aloxory. All rights reserved.
# Contact: maloxory@gmail.com

# Prompt user for the DN
$OU = Read-Host "Please enter DN address of the OU"

# Prompt user for the user name prefix
$usernamePrefix = Read-Host "Please enter the user name prefix"

# Prompt user for the user password
$password = Read-Host "Please enter password for the new accounts"

# Prompt user for the starting range
$startRange = Read-Host "Please enter the starting digit" 
$startRange = [int]$startRange

# Prompt user for the ending range
$endRange = Read-Host "Please enter the ending digit"
$endRange = [int]$endRange


# Loop to create users ComputerName_000 to ComputerName_025
for ($i = $startRange; $i -le $endRange; $i++) {
    # Format the username
    $username = "{0}_{1:D3}" -f $usernamePrefix, $i

    # Create a secure string for the password
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

    # Define user properties
    $userParams = @{
        SamAccountName = $username
        Name = $username
        UserPrincipalName = "$username@yourdomain.com"
        Path = $OU
        AccountPassword = $securePassword
        Enabled = $true
    }

    # Create the user
    New-ADUser @userParams

    # Optionally, set the password to never expire
    Set-ADUser $username -PasswordNeverExpires $true
}

Write-Host "Users created successfully."

pause