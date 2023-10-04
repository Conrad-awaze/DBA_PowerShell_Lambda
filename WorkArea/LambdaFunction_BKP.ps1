Write-Host "Importing Modules"
Import-Module "AWS.Tools.Common",'AWS.Tools.DynamoDBv2','AWS.Tools.Lambda','PSTeams','AWS.Tools.EC2','AWS.Tools.SimpleSystemsManagement'

function handler
{
    [cmdletbinding()]
    param(
        [parameter()]
        $LambdaInput,

        [parameter()]
        $LambdaContext,
        
        [string]$GUID1  = '10ed1b71-1a9f-4427-a5cb-8ffc041487cd@bd846b68-132a-4a46-b1e7-d090e168c0a2',
        
        [string]$GUID2  = '6eda4df9f3a246c582a0362c83e0ec58/34d83ea3-495b-45f0-9efa-2a30f32d086e'
        
    )
    
    $URI            = "https://awazecom.webhook.office.com/webhookb2/$($GUID1)/IncomingWebhook/$($GUID2)"
    
    $InstanceID     = $(([regex]::Matches("$($LambdaInput.resources)", '\w+\W+\w+$')).Value)
    $EC2            =  (Get-EC2Instance -InstanceId $InstanceID).Instances
    
    $EC2Instance    = [PSCustomObject]@{

        Name        = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value
        Owner       = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Owner).Value
        State       = $EC2.State.Name.Value.ToUpper()
        Type        = $EC2.InstanceType.Value
        InstanceId  = $EC2.InstanceId
        KeyName     = $EC2.KeyName
        LaunchTime  = $EC2.LaunchTime
    }
    
    $LambdaCon      = [PSCustomObject]@{

        LogStream   = $LambdaContext.LogStreamName
        LogGroup    = $LambdaContext.LogGroupName
        Function    = $LambdaContext.FunctionName
        Time        = $LambdaInput.time
        Memory      = $LambdaContext.MemoryLimitInMB

    }
    
    $AWS = @{

        # InstanceID          = get-ec2instancemetadata -Category instanceid
        Hostname            = ($EC2Instance.Name).ToLower()
        # source              = "ec2.events"
        # NameDetails         = "/prod/ILT-Elasticity/Replicated/$($EC2Instance.Name)"
        StartedParam        = "/prod/ILT-Elasticity/Started/$(($EC2Instance.Name).ToLower())"
        OfflineParam        = "/prod/ILT-Elasticity/offline-ilts/$(($EC2Instance.Name).ToLower())"
        StartedforReplParam = "/prod/ILT-Elasticity/StartedforReplicationCatchup/" + ($EC2Instance.Name).ToLower()
        PatchingParam       = "/prod/ILT-Elasticity/Patching/$(($EC2Instance.Name).ToLower())"
        DescriptionDetails  = "Replication is now completed on $($EC2Instance.Name). This Parameter will be deleted by ILT-Elasticity once the server has been added to the ILT Target Group"
        OfflineDescr        = "Replication is now completed on $($EC2Instance.Name) and the server has been shutdown. This Parameter will be deleted by ILT-Elasticity once the server has been brought up once again"
    }
    
    #region Parameter Check
    $StartedParameter   = " "
    $PatchingParameter  = " "

    try {
        
        $StartedParameter   =  Get-SSMParameter -Name $AWS.StartedParam
        
    }
    catch {

        Write-Host "No 'Started' Parameter Found"
        Write-Host "Started Parameter error - $_"
    }

    try {
        
        $PatchingParameter   =  Get-SSMParameter -Name $AWS.PatchingParam
        
    }
    catch {

        Write-Host "No 'Patching' Parameter Found"
        Write-Host "Patching Parameter error - $_"
        
    }
    
    #endregion
    
    $ParameterList = (Get-SSMParameterList).Name

    if ($ParameterList.Contains($StartedParameter.Name)) {
        
        $StartupType = "Standard"
        Write-Host "Setting Startup Type to 'Standard' due to presence of Parameter $($AWS.StartedParam)"

    }elseif ($ParameterList.Contains($PatchingParameter.Name)) {

        $StartupType = "Patching"
        Write-Host "Setting Startup Type to 'Patching' due to presence of Parameter $($AWS.PatchingParam)"

    }else {
    
        $StartupType = "Manual"
        Write-Host "No Parameters found"
    }
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    # Send Teams Notification

    switch ($($EC2Instance.State)) {
        
        PENDING { 
            
            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
                    
                    switch ($StartupType) {
                        
                        Standard { 

                            New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server started up by AutoScaling" -Color Accent -HorizontalAlignment Center
                            
                        }
                        
                        Patching {

                            New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server started up for Patching" -Color Accent -HorizontalAlignment Center
                            
                        }
                        
                        Manual {
                            
                            New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - No parameters found. Manual Start Up" -Color Accent -HorizontalAlignment Center
                        }
                    }
                    
                    New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
                    New-AdaptiveFactSet {
                
                        New-AdaptiveFact -Title 'Server State' -Value $($EC2Instance.State)
                        
                    } -Separator Medium
                    
                }
            }
            
        }

        RUNNING {

            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
            
                    New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server start up completed " -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
                    
                }
            } -Action {
                
                New-AdaptiveAction -Title "Server Details" -Body   {
                    New-AdaptiveTextBlock -Text "EC2 Server Details" -Weight Bolder -Size Large -Color Accent #-HorizontalAlignment Center
                    New-AdaptiveFactSet {
                        
                        New-AdaptiveFact -Title 'State' -Value $EC2Instance.State
                        New-AdaptiveFact -Title 'Name' -Value $EC2Instance.Name
                        New-AdaptiveFact -Title 'Owner' -Value $EC2Instance.Owner
                        New-AdaptiveFact -Title 'Type' -Value $EC2Instance.Type
                        New-AdaptiveFact -Title 'InstanceId' -Value $EC2Instance.InstanceId
                        New-AdaptiveFact -Title 'KeyName' -Value $EC2Instance.KeyName
                        New-AdaptiveFact -Title 'LaunchTime' -Value $EC2Instance.LaunchTime
                        
                    } -Separator Medium 
                    
                } 
                
                New-AdaptiveAction -Title "Lambda Details" -Body   {
                    
                    New-AdaptiveTextBlock -Text "Lambda Details" -Weight Bolder -Size Large -Color Accent # -HorizontalAlignment Center
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
            
                    New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server shut down started" -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good 
                    New-AdaptiveFactSet {
                
                        New-AdaptiveFact -Title 'Server State' -Value $($EC2Instance.State)
                        
                    } -Separator Medium 
                    
                }
            }

        }

        STOPPED {

            New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
                New-AdaptiveContainer {
            
                    New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server shut down completed" -Color Accent -HorizontalAlignment Center
                    New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
                    New-AdaptiveFactSet {
                
                        New-AdaptiveFact -Title 'Server State' -Value $($EC2Instance.State)
                        
                    } -Separator Medium 
                    
                }
            }

        }
    }
    
    Write-Host "Teams notification sent"
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    
}