#$VerbosePreference = "continue"
#$VerbosePreference = "SilentlyContinue"
#Write-Verbose "Run script init tasks before handler"
Write-Verbose "Importing Modules"
Import-Module "AWS.Tools.Common",'AWS.Tools.DynamoDBv2','AWS.Tools.Lambda','PSTeams'
function handler
{
    [cmdletbinding()]
    param(
        [parameter()]
        $LambdaInput,

        [parameter()]
        $LambdaContext,
        
        [string]$GUID1  = '10ed1b71-1a9f-4427-a5cb-8ffc041487cd@bd846b68-132a-4a46-b1e7-d090e168c0a2',
        
        [string]$GUID2  = '255b3917962f40cb872ad6bac331d797/34d83ea3-495b-45f0-9efa-2a30f32d086e',
        
        [string]$URI    = "https://awazecom.webhook.office.com/webhookb2/$($GUID1)/IncomingWebhook/$($GUID2)"
        
    )
    
    Write-Host "Function Remaining Time: $($LambdaContext.GetRemainingTimeInMillis())"
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    # Send Teams Notification
    
    New-AdaptiveCard -Uri $URI -VerticalContentAlignment center {

        New-AdaptiveTextBlock -Size ExtraLarge -Weight Bolder -Text 'Notification from Lambda Function' -Color Accent -HorizontalAlignment Center
        New-AdaptiveTextBlock -Text "$((Get-Date).GetDateTimeFormats()[13])" -Subtle -Wrap -HorizontalAlignment Center
        New-AdaptiveFactSet {

                    New-AdaptiveFact -Title "Function" -Value $LambdaContext.FunctionName
                    New-AdaptiveFact -Title "Version" -Value $LambdaContext.FunctionVersion
                    New-AdaptiveFact -Title "Milliseconds" -Value $LambdaContext.GetRemainingTimeInMillis()
                    New-AdaptiveFact -Title "Memory(MB)" -Value $LambdaContext.MemoryLimitInMB 
                    New-AdaptiveFact -Title "Log Group" -Value $LambdaContext.LogGroupName
                    New-AdaptiveFact -Title "Log Stream" -Value $LambdaContext.LogStreamName
                    
                     
                }  -Separator Medium
        
    }   -FullWidth
    
    Write-Host "Teams Notification Sent"
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    
    # Write-Host 'Function name:' $LambdaContext.FunctionName
    # Write-Host 'Remaining milliseconds:' $LambdaContext.RemainingTime.TotalMilliseconds
    # Write-Host 'Log group name:' $LambdaContext.LogGroupName
    # Write-Host 'Log stream name:' $LambdaContext.LogStreamName
    
    # Get-AWSRegion
    # Write-Host "PowerShell Version - $($PSVersionTable.PSVersion)"
    # $Commands = $(Get-Command -Module 'PSTeams')
    # Write-Host $Commands.Count
    #Get-DDBTableList
    # Write-Host (Get-LMLayerList).LayerName
    # Get-Command -Module "AWS.Tools.Lambda"
    
    
}
