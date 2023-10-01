Write-Host "Importing Modules"
Import-Module "AWS.Tools.Common",'AWS.Tools.DynamoDBv2','AWS.Tools.Lambda','PSTeams','AWS.Tools.EC2'

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
    
    $InstanceID = $(([regex]::Matches("$($LambdaInput.resources)", '\w+\W+\w+$')).Value)
    $EC2 =  (Get-EC2Instance -InstanceId $InstanceID).Instances
    
    $EC2Instance    = [PSCustomObject]@{

        Name        = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value
        Owner       = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Owner).Value
        State       = $($EC2.State.Name.Value.ToUpper())
        Type        = $EC2.InstanceType.Value
        InstanceId  = $EC2.InstanceId
        KeyName     = $EC2.KeyName
        LaunchTime  = $EC2.LaunchTime
    }
    
    $LambdaCon      = [PSCustomObject]@{

        LogStream   = $LambdaContext.LogStreamName
        LogGroup    = $LambdaContext.LogGroupName
        Function    = $LambdaContext.FunctionName
        Time        = $($LambdaInput.time)
        Memory      = $LambdaContext.MemoryLimitInMB

    }
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    # Send Teams Notification

    switch ($($EC2Instance.State)) {

        PENDING { 
            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
            
                    New-AdaptiveTextBlock -Size ExtraLarge -Weight Bolder -Text "$($EC2Instance.Name) - Server Started Up" -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$((Get-Date).GetDateTimeFormats()[12])" -Subtle -HorizontalAlignment Center -Spacing None
                    New-AdaptiveFactSet {
                
                        New-AdaptiveFact -Title 'State' -Value $($EC2Instance.State)
                        
                    } -Separator Medium 
                    
                }
            }
         }

        RUNNING {

            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
            
                    New-AdaptiveTextBlock -Size ExtraLarge -Weight Bolder -Text "Server $($EC2Instance.Name) $($EC2Instance.State)" -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$((Get-Date).GetDateTimeFormats()[12])" -Subtle -HorizontalAlignment Center -Spacing None
                    
                }
            } -Action {
                New-AdaptiveAction -Title "Server Details" -Body   {
                    New-AdaptiveTextBlock -Text "Server Details" -Weight Bolder -Size Large -Color Accent -HorizontalAlignment Center
                    New-AdaptiveFactSet {
                        
                        New-AdaptiveFact -Title 'Name' -Value $EC2Instance.Name
                        New-AdaptiveFact -Title 'Owner' -Value $EC2Instance.Owner
                        New-AdaptiveFact -Title 'State' -Value $EC2Instance.State
                        New-AdaptiveFact -Title 'Type' -Value $EC2Instance.Type
                        New-AdaptiveFact -Title 'InstanceId' -Value $EC2Instance.InstanceId
                        New-AdaptiveFact -Title 'KeyName' -Value $EC2Instance.KeyName
                        New-AdaptiveFact -Title 'LaunchTime' -Value $EC2Instance.LaunchTime
                    } -Separator Medium 
                } 
                New-AdaptiveAction -Title "Lambda Details" -Body   {
                    New-AdaptiveTextBlock -Text "Lambda Details" -Weight Bolder -Size Large -Color Accent -HorizontalAlignment Center
                    New-AdaptiveFactSet {
                        
                        New-AdaptiveFact -Title "LogStream" -Value $LambdaCon.LogStream
                        New-AdaptiveFact -Title "LogGroup" -Value $LambdaCon.LogGroup
                        New-AdaptiveFact -Title "Function" -Value $LambdaCon.Function
                        New-AdaptiveFact -Title "Time" -Value $LambdaCon.Time
                        New-AdaptiveFact -Title "Memory(MB)" -Value $LambdaCon.Memory 
                        
                    } -Separator Medium 
                }
                
            }

        }

        STOPPING {

            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
            
                    New-AdaptiveTextBlock -Size ExtraLarge -Weight Bolder -Text "Server $($EC2Instance.Name) is shutting down" -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$((Get-Date).GetDateTimeFormats()[12])" -Subtle -HorizontalAlignment Center -Spacing None
                    New-AdaptiveFactSet {
                
                        New-AdaptiveFact -Title 'State' -Value $($EC2Instance.State)
                        
                    } -Separator Medium 
                    
                }
            }

        }

        STOPPED {

            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
            
                    New-AdaptiveTextBlock -Size ExtraLarge -Weight Bolder -Text " $($EC2Instance.Name) - Server Shut Down" -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$((Get-Date).GetDateTimeFormats()[12])" -Subtle -HorizontalAlignment Center -Spacing None
                    New-AdaptiveFactSet {
                
                        New-AdaptiveFact -Title 'State' -Value $($EC2Instance.State)
                        
                    } -Separator Medium 
                    
                }
            }

        }
    }
    
    
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    
}