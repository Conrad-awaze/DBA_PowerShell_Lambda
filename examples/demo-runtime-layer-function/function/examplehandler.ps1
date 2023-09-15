#$VerbosePreference = "continue"
#$VerbosePreference = "SilentlyContinue"
Write-Verbose "Run script init tasks before handler"
Write-Verbose "Importing Modules"
Import-Module "AWS.Tools.Common",'AWS.Tools.CloudWatchLogs','AWS.Tools.EC2','AWS.Tools.CloudWatch'
function handler
{
    [cmdletbinding()]
    param(
        [parameter()]
        $LambdaInput,

        [parameter()]
        $LambdaContext
    )
    Write-Verbose "Run handler function from script1"
    Write-Verbose "Function Remaining Time: $($LambdaContext.GetRemainingTimeInMillis())"
    Write-Host "PowerShell Verion: $($PSVersionTable.PSVersion)"
    Write-Host "Cloud commands: $(Get-Command -Module AWS.Tools.CloudWatch)"
}
