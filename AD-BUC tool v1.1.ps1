<#
    Title: Active Directory Bulk User Creator v1.1
    Copyright© 2024 Magdy Aloxory. All rights reserved.
    Contact: maloxory@gmail.com
#>

# Check if the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch the script with administrator privileges
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Function to center text
function CenterText {
    param (
        [string]$text,
        [int]$width
    )
    
    $textLength = $text.Length
    $padding = ($width - $textLength) / 2
    return (" " * [math]::Max([math]::Ceiling($padding), 0)) + $text + (" " * [math]::Max([math]::Floor($padding), 0))
}

# Function to create a border
function CreateBorder {
    param (
        [string[]]$lines,
        [int]$width
    )

    $borderLine = "+" + ("-" * $width) + "+"
    $borderedText = @($borderLine)
    foreach ($line in $lines) {
        $borderedText += "|$(CenterText $line $width)|"
    }
    $borderedText += $borderLine
    return $borderedText -join "`n"
}

# Display script information with border
$title = "Active Directory Bulk User Creator (AD-BUC) v1.1"
$copyright = "Copyright 2024 Magdy Aloxory. All rights reserved."
$contact = "Contact: maloxory@gmail.com"
$maxWidth = 60

$infoText = @($title, $copyright, $contact)
$borderedInfo = CreateBorder -lines $infoText -width $maxWidth

Write-Host $borderedInfo -ForegroundColor Cyan


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

Write-Host "Users created successfully." -ForegroundColor Green

pause