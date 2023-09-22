#$VerbosePreference = "continue"
#$VerbosePreference = "SilentlyContinue"
Write-Verbose "Run script init tasks before handler"
Write-Verbose "Importing Modules"
Import-Module "AWS.Tools.Common",'AWS.Tools.DynamoDBv2','AWS.Tools.Lambda','PSTeams'
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
    Write-Host "Function Remaining Time: $($LambdaContext.GetRemainingTimeInMillis())"

    $GUID1 = '10ed1b71-1a9f-4427-a5cb-8ffc041487cd@bd846b68-132a-4a46-b1e7-d090e168c0a2'
    $GUID2 = '255b3917962f40cb872ad6bac331d797/34d83ea3-495b-45f0-9efa-2a30f32d086e'
    $URI    = "https://awazecom.webhook.office.com/webhookb2/$($GUID1)/IncomingWebhook/$($GUID2)"

    New-AdaptiveCard -Uri $URI -VerticalContentAlignment center {
        New-AdaptiveTextBlock -Size ExtraLarge -Weight Bolder -Text 'Test' -Color Accent -HorizontalAlignment Center
        New-AdaptiveColumnSet {
            New-AdaptiveColumn {
                New-AdaptiveTextBlock -Size 'Medium' -Text 'Test Card Title 1' -Color Dark
                New-AdaptiveTextBlock -Size 'Medium' -Text 'Test Card Title 1' -Color Light
            }
            New-AdaptiveColumn {
                New-AdaptiveTextBlock -Size 'Medium' -Text 'Test Card Title 1' -Color Warning
                New-AdaptiveTextBlock -Size 'Medium' -Text 'Test Card Title 1' -Color Good
            }
        }
    }   -FullWidth #-MinimumHeight 300 -Verbose

    # Get-AWSRegion
    # Write-Host "PowerShell Version - $($PSVersionTable.PSVersion)"
    # $Commands = $(Get-Command -Module 'PSTeams')
    # Write-Host $Commands.Count
    # Write-Host "$(Get-DDBTableList)"
    # Write-Host "$((Get-LMLayerList).LayerName)"
    # Write-Host "$((Get-LMFunctionList).FunctionName)"
    # Write-Host (Get-LMLayerList).LayerName
    # Get-Command -Module "AWS.Tools.Lambda"
}
