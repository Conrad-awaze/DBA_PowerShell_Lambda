#$VerbosePreference = "continue"
#$VerbosePreference = "SilentlyContinue"
Write-Verbose "Run script init tasks before handler"
Write-Verbose "Importing Modules"
Import-Module "AWS.Tools.Common",'AWS.Tools.DynamoDBv2','AWS.Tools.Lambda'
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
    # Get-AWSRegion
    Write-Host "PowerShell Version - $($PSVersionTable.PSVersion)"
}
