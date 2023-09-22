param (
    # A list of AWS.Tools modules to embed in the Lambda layer.
    [string[]]$ModuleList,

    # The folder path where the layer content should be created.
    [ValidateNotNullOrEmpty()]
    [string]$LayerPath, #= ([System.IO.Path]::Combine($PSScriptRoot, 'layers', 'modulesLayer')),

    # The URL to the AWS.Tools zip file.
    [string]$AWSToolsSource = 'https://sdk-for-net.amazonwebservices.com/ps/v4/latest/AWS.Tools.zip',

    # The staging path where the AWS Tools for PowerShell will be extracted
    [string]$ModuleStagingPath = ([System.IO.Path]::Combine($PSScriptRoot, 'layers', 'staging')),

    # Can be used to prevent the downloading and expansions of the AWS.Tools source.
    [switch]$SkipZipFileExpansion
)

#################
# PSTeams #
#################

Write-Host "Downloading PSTeams" -foregroundcolor "green"

Save-Module -Name PSTeams -Path "$LayerPath\modules" -Force

$File = Get-ChildItem -Path  ([System.IO.Path]::Combine($LayerPath, 'modules', 'PSTeams')) -Recurse -Filter '*.psd1'

$Content =  Get-Content -Path $File 
$Content.Replace('RequiredModules', '# RequiredModules') | Set-Content -Path $File.FullName