Write-Host "Importing Modules"

Import-Module "AWS.Tools.Common",'AWS.Tools.DynamoDBv2','AWS.Tools.Lambda','PSTeams','AWS.Tools.EC2'
Import-Module 'AWS.Tools.SecretsManager'
Import-Module 'AWS.Tools.SimpleSystemsManagement'

function handler
{
    [cmdletbinding()]
    param(
        
        [parameter()]
        $LambdaInput,

        [parameter()]
        $LambdaContext
        
    )

    Write-Host " PowerShell Version: $($PSVersionTable.PSVersion)"

    # $Region             = 'eu-west-2'
    # $AWSAccount         = 'AWS - VRUK-A'
    # $KeysCommonAccount  = 'DBAKeys-Common'
    # $KeysCommon         = (Get-SECSecretValue -SecretId $KeysCommonAccount).SecretString | ConvertFrom-Json
    # $GUID1              = '10ed1b71-1a9f-4427-a5cb-8ffc041487cd@bd846b68-132a-4a46-b1e7-d090e168c0a2'
    # $GUID2              = '6eda4df9f3a246c582a0362c83e0ec58/34d83ea3-495b-45f0-9efa-2a30f32d086e'
    # $URI                = "https://awazecom.webhook.office.com/webhookb2/$GUID1/IncomingWebhook/$GUID2"
    # $EventType          = "AWS"
    # $dynamoDBTableName  = 'DBA-EC2StateMonitor'
    
    # $InstanceID         = $(([regex]::Matches("$($LambdaInput.resources)", '\w+\W+\w+$')).Value)
    # $EC2                = (Get-EC2Instance -InstanceId $InstanceID).Instances
    
    # $EC2Instance    = [PSCustomObject]@{

    #     Name        = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value.ToUpper()
    #     TagState    = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq 'ILT-Elasticity-Instance-State').Value
    #     State       = $EC2.State.Name.Value.ToUpper()
    #     Type        = $EC2.InstanceType.Value
    #     InstanceId  = $EC2.InstanceId
    #     KeyName             = $EC2.KeyName
    #     LaunchTime          = $EC2.LaunchTime
    #     AvailabilityZone    = $EC2.Placement.AvailabilityZone
    #     PlatformDetails     = $EC2.PlatformDetails
        
    # }
    
    # $LambdaCon      = [PSCustomObject]@{

    #     LogStream   = $LambdaContext.LogStreamName
    #     LogGroup    = $LambdaContext.LogGroupName
    #     Function    = $LambdaContext.FunctionName
    #     Time        = $LambdaInput.time
    #     Memory      = $LambdaContext.MemoryLimitInMB

    # }
    
    # $AWS = @{

    #     Hostname            = ($EC2Instance.Name).ToLower()
    #     # source              = "ec2.events"
    #     # NameDetails         = "/prod/ILT-Elasticity/Replicated/$($EC2Instance.Name)"
    #     StartedParam        = "/prod/ILT-Elasticity/Started/$(($EC2Instance.Name).ToLower())"
    #     OfflineParam        = "/prod/ILT-Elasticity/offline-ilts/$(($EC2Instance.Name).ToLower())"
    #     PatchingParam       = "/prod/ILT-Elasticity/Patching/$(($EC2Instance.Name).ToLower())"
    #     MaintModeParam      = "/prod/ILT-Elasticity/InMaintenanceMode/$(($EC2Instance.Name).ToLower())"
        
    # }
    
    # #---------------------------------------------------------------------------------------------------------------------
    
    # #region DynamoDB Table Check and Setup

    # $TableList  = Get-DDBTables -AccessKey $KeysCommon.AccessKey -SecretKey $KeysCommon.SecretKey -Region $Region
    
    # if ($TableList -contains $dynamoDBTableName) {
        
    #     Write-Host "DynamoDB - Table [$dynamoDBTableName] already exists"
    # }
    # else {

    #     Write-Host "DynamoDB - Creating table - [$dynamoDBTableName]...!!!!"

    #     # Create KeySchema
    #     $Schema = New-DDBTableSchema
    #     $Schema |   Add-DDBKeySchema -KeyName "PK" -KeyDataType "S" -KeyType HASH | 
    #                 Add-DDBKeySchema -KeyName "SK" -KeyType RANGE -KeyDataType "S" 

    #     # Create New Table
        
    #     $NewTableParameters = @{
    #         TableName       = $dynamoDBTableName
    #         Schema          = $Schema
    #         ReadCapacity    = 10
    #         WriteCapacity   = 5
    #         AccessKey       = $KeysCommon.AccessKey
    #         SecretKey       = $KeysCommon.SecretKey
    #         Region          = $Region
    #     }
    #     New-DDBTable @NewTableParameters
        
    #     $GetTableParameters = @{
                
    #         TableName       = $dynamoDBTableName
    #         AccessKey       = $KeysCommon.AccessKey
    #         SecretKey       = $KeysCommon.SecretKey
    #         Region          = $Region
            
    #     }

    #     # Confirm Table is active
    #     while ((Get-DDBTable @GetTableParameters).TableStatus.Value -ne 'Active') {

    #         Start-Sleep 5
            
    #         $TableStatus = (Get-DDBTable @GetTableParameters).TableStatus.Value
            
    #         switch ($TableStatus) {
                
    #             Active { Write-Host "DynamoDB - Table Status - $TableStatus" }
    #             Default {Write-Host "DynamoDB - Table Status - $TableStatus"}
                
    #         }
    #     }
    # }

    # #endregion
        
    # #---------------------------------------------------------------------------------------------------------------------
    # # Check Parameters
    
    # $CurrentParameter = (Get-SSMParameterList).Name | Where-Object  {$_ -match $(($EC2Instance.Name).ToLower())}
    
    # if ($CurrentParameter.Count -eq 1) {
    
    #     switch ($CurrentParameter) {
            
    #         {$_ -match 'InMaintenanceMode'} {
                
    #             $StartupType    = "Maintenance"
    #             $Parameter      = $($AWS.MaintModeParam)
    #             Write-Host "Setting Startup Type to 'Maintenance' due to presence of Parameter $($AWS.MaintModeParam)"
                
    #         }
    #         {$_ -match 'Patching'} { 
                
    #             $StartupType    = "Patching"
    #             $Parameter      = $($AWS.PatchingParam)
    #             Write-Host "Setting Startup Type to 'Patching' due to presence of Parameter $($AWS.PatchingParam)"
                
    #         }
    #         {$_ -match 'Started'} { 
                
    #             $StartupType    = "AutoScaling"
    #             $Parameter      = $($AWS.StartedParam)
    #             Write-Host "Setting Startup Type to 'Standard' due to presence of Parameter $($AWS.StartedParam)"

    #         }
    #         Default {
                
    #             $StartupType    = "Manual"
    #             $Parameter      = "No Parameters Found"
    #             Write-Host "No Parameters found"

    #         }
    #     }
        
    # }else {
        
    #     Write-Host "ERROR: More than one paramater found. Stopping the script...!!!"
    #     Write-Host "$CurrentParameter"
    #     exit
        
    # }

    # #-----------------------------------------------------------------------------------------------------------------------------------------------
    # # Send Teams Notification
    
    # function Set-DaDDBEvent {
        
    #     param (

    #         $AWSAccount,
    #         $AvailabilityZone,
    #         $PlatformDetails,
    #         $dynamoDBTableName,
    #         $State, 
    #         $TagState,
    #         $EC2Instance,
    #         $StartupType,
    #         $LogGroup,
    #         $LogStream,
    #         $LambdaFunction,
    #         $InstanceId,
    #         $EventType,
    #         $Parameter,
    #         $AccessKey,
    #         $SecretKey,
    #         $Region

    #     )

    #     $dynamoDBEvent = @{

    #         PK                  = "$(Get-Date -format yyyy-MM-dd)"
    #         SK                  = "$AWSAccount#$State#$(get-date -format "HH:mm:ss:ms")"
    #         EventTime           = "$(get-date -format "yyyy-MM-dd HH:mm:ss")"
    #         AWSAccount          = $AWSAccount 
    #         AvailabilityZone    = $AvailabilityZone
    #         PlatformDetails     = $PlatformDetails
    #         State               = $State
    #         TagState            = $TagState
    #         EC2Instance         = $EC2Instance
    #         StartupType         = $StartupType
    #         LogGroup            = $LogGroup
    #         LogStream           = $LogStream
    #         LambdaFunction      = $LambdaFunction
    #         InstanceId          = $InstanceId
    #         EventType           = $EventType
    #         Parameter           = $Parameter
            
            
    #     } | ConvertTo-DDBItem

    #     Set-DDBItem -TableName $dynamoDBTableName -Item $dynamoDBEvent -AccessKey $AccessKey -SecretKey $SecretKey -Region $Region

    #     Write-Host "DynamoDB - [$State] Event written to table $dynamoDBTableName"
        
    # }
    
    # #-----------------------------------------------------------------------------------------------------------------------------------------------
    
    # Write-Host "Server State - $($EC2Instance.State)"
    
    # switch ($($EC2Instance.State)) {
        
    #     PENDING { 
            
    #         $ddbEventParameters = @{

    #             AWSAccount          = $AWSAccount
    #             AvailabilityZone    = $EC2Instance.AvailabilityZone
    #             PlatformDetails     = $EC2Instance.PlatformDetails
    #             dynamoDBTableName   = $dynamoDBTableName
    #             State               = $EC2Instance.State
    #             TagState            = $EC2Instance.TagState
    #             EC2Instance         = $EC2Instance.Name
    #             StartupType         = $StartupType
    #             LogGroup            = $LambdaCon.LogGroup
    #             LogStream           = $LambdaCon.LogStream
    #             LambdaFunction      = $LambdaCon.Function
    #             InstanceId          = $EC2Instance.InstanceId
    #             EventType           = $EventType
    #             Parameter           = $Parameter
    #             AccessKey           = $KeysCommon.AccessKey
    #             SecretKey           = $KeysCommon.SecretKey
    #             Region              = $Region
                
    #         }

    #         Set-DaDDBEvent @ddbEventParameters
            
    #         #-----------------------------------------------------------------------------------------------------------------------------------------------
            
    #         [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
            
    #         New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
    #             New-AdaptiveContainer {
                    
    #                 switch ($StartupType) {
                        
    #                     Manual {
                            
    #                         New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - No parameters found. Manual Start Up" -Color Accent -HorizontalAlignment Center
    #                     }
                        
    #                     Default { 

    #                         New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server Started Up [$StartupType]" -Color Accent -HorizontalAlignment Center
                            
    #                     }
    #                 }
                    
    #                 New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
    #                 New-AdaptiveFactSet {
                
    #                     New-AdaptiveFact -Title 'Server State' -Value $($EC2Instance.State)
                        
    #                 } -Separator Medium
                    
    #             }
    #         }
            
    #     }

    #     RUNNING {
            
    #         $ddbEventParameters = @{

    #             AWSAccount          = $AWSAccount
    #             AvailabilityZone    = $EC2Instance.AvailabilityZone
    #             PlatformDetails     = $EC2Instance.PlatformDetails
    #             dynamoDBTableName   = $dynamoDBTableName
    #             State               = $EC2Instance.State
    #             TagState            = $EC2Instance.TagState
    #             EC2Instance         = $EC2Instance.Name
    #             StartupType         = $StartupType
    #             LogGroup            = $LambdaCon.LogGroup
    #             LogStream           = $LambdaCon.LogStream
    #             LambdaFunction      = $LambdaCon.Function
    #             InstanceId          = $EC2Instance.InstanceId
    #             EventType           = $EventType
    #             Parameter           = $Parameter
    #             AccessKey           = $KeysCommon.AccessKey
    #             SecretKey           = $KeysCommon.SecretKey
    #             Region              = $Region
                
    #         }

    #         Set-DaDDBEvent @ddbEventParameters
            
    #         #-----------------------------------------------------------------------------------------------------------------------------------------------
            
    #         [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
            
    #         New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
    #             New-AdaptiveContainer {
            
    #                 New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server Start Up Completed [$StartupType]" -Color Accent -HorizontalAlignment Center
    #                 New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
                    
    #             }
    #         } -Action {
                
    #             New-AdaptiveAction -Title "Server Details" -Body   {
    #                 New-AdaptiveTextBlock -Text "EC2 Server Details" -Weight Bolder -Size Large -Color Accent #-HorizontalAlignment Center
    #                 New-AdaptiveFactSet {
                        
    #                     New-AdaptiveFact -Title 'State' -Value $EC2Instance.State
    #                     New-AdaptiveFact -Title 'Name' -Value $EC2Instance.Name

    #                     New-AdaptiveFact -Title 'PlatformDetails' -Value $EC2Instance.PlatformDetails
    #                     New-AdaptiveFact -Title 'Tag-State' -Value $EC2Instance.TagState
    #                     New-AdaptiveFact -Title 'Type' -Value $EC2Instance.Type
    #                     New-AdaptiveFact -Title 'InstanceId' -Value $EC2Instance.InstanceId
    #                     New-AdaptiveFact -Title 'KeyName' -Value $EC2Instance.KeyName
    #                     New-AdaptiveFact -Title 'LaunchTime' -Value $EC2Instance.LaunchTime
                        
    #                 } -Separator Medium 
                    
    #             } 
                
    #             New-AdaptiveAction -Title "AWS Details" -Body   {
                    
    #                 New-AdaptiveTextBlock -Text "AWS Details" -Weight Bolder -Size Large -Color Accent # -HorizontalAlignment Center
    #                 New-AdaptiveFactSet {
                        
    #                     New-AdaptiveFact -Title "Parameter" -Value $Parameter
    #                     New-AdaptiveFact -Title 'AWS Account' -Value $AWSAccount
    #                     New-AdaptiveFact -Title 'AvailabilityZone' -Value $EC2Instance.AvailabilityZone
    #                     New-AdaptiveFact -Title "Function" -Value $LambdaCon.Function
    #                     New-AdaptiveFact -Title "LogGroup" -Value $LambdaCon.LogGroup
    #                     New-AdaptiveFact -Title "LogStream" -Value $LambdaCon.LogStream
    #                     New-AdaptiveFact -Title "Time" -Value $LambdaCon.Time
    #                     New-AdaptiveFact -Title "Memory(MB)" -Value $LambdaCon.Memory 
                        
    #                 } -Separator Medium 
                    
    #             }
                
    #         }

    #     }

    #     STOPPING {
            
    #         $ddbEventParameters = @{

    #             AWSAccount          = $AWSAccount
    #             AvailabilityZone    = $EC2Instance.AvailabilityZone
    #             PlatformDetails     = $EC2Instance.PlatformDetails
    #             dynamoDBTableName   = $dynamoDBTableName
    #             State               = $EC2Instance.State
    #             TagState            = $EC2Instance.TagState
    #             EC2Instance         = $EC2Instance.Name
    #             StartupType         = $StartupType
    #             LogGroup            = $LambdaCon.LogGroup
    #             LogStream           = $LambdaCon.LogStream
    #             LambdaFunction      = $LambdaCon.Function
    #             InstanceId          = $EC2Instance.InstanceId
    #             EventType           = $EventType
    #             Parameter           = $Parameter
    #             AccessKey           = $KeysCommon.AccessKey
    #             SecretKey           = $KeysCommon.SecretKey
    #             Region              = $Region
                
    #         }
            
    #         Set-DaDDBEvent @ddbEventParameters
            
    #         #-----------------------------------------------------------------------------------------------------------------------------------------------
            
    #         New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
    #             New-AdaptiveContainer {
            
    #                 New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server Shut Down Started" -Color Accent -HorizontalAlignment Center
    #                 New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good 
    #                 New-AdaptiveFactSet {
                
    #                     New-AdaptiveFact -Title 'Server State' -Value $($EC2Instance.State)
                        
    #                 } -Separator Medium 
                    
    #             }
    #         }

    #     }

    #     STOPPED {
            
    #         $ddbEventParameters = @{

    #             AWSAccount          = $AWSAccount
    #             AvailabilityZone    = $EC2Instance.AvailabilityZone
    #             PlatformDetails     = $EC2Instance.PlatformDetails
    #             dynamoDBTableName   = $dynamoDBTableName
    #             State               = $EC2Instance.State
    #             TagState            = $EC2Instance.TagState
    #             EC2Instance         = $EC2Instance.Name
    #             StartupType         = $StartupType
    #             LogGroup            = $LambdaCon.LogGroup
    #             LogStream           = $LambdaCon.LogStream
    #             LambdaFunction      = $LambdaCon.Function
    #             InstanceId          = $EC2Instance.InstanceId
    #             EventType           = $EventType
    #             Parameter           = $Parameter
    #             AccessKey           = $KeysCommon.AccessKey
    #             SecretKey           = $KeysCommon.SecretKey
    #             Region              = $Region
                
    #         }

    #         Set-DaDDBEvent @ddbEventParameters
            
    #         #-----------------------------------------------------------------------------------------------------------------------------------------------
            
    #         New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
    #             New-AdaptiveContainer {
            
    #                 New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "$($EC2Instance.Name) - Server Shut Down Completed [$StartupType]" -Color Accent -HorizontalAlignment Center
    #                 New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
                    
    #             }
    #         } -Action {
                
    #             New-AdaptiveAction -Title "Server Details" -Body   {
    #                 New-AdaptiveTextBlock -Text "EC2 Server Details" -Weight Bolder -Size Large -Color Accent #-HorizontalAlignment Center
    #                 New-AdaptiveFactSet {
                        
    #                     New-AdaptiveFact -Title 'State' -Value $EC2Instance.State
    #                     New-AdaptiveFact -Title 'Name' -Value $EC2Instance.Name
    #                     New-AdaptiveFact -Title 'PlatformDetails' -Value $EC2Instance.PlatformDetails
    #                     New-AdaptiveFact -Title 'Tag-State' -Value $EC2Instance.TagState
    #                     New-AdaptiveFact -Title 'Type' -Value $EC2Instance.Type
    #                     New-AdaptiveFact -Title 'InstanceId' -Value $EC2Instance.InstanceId
    #                     New-AdaptiveFact -Title 'KeyName' -Value $EC2Instance.KeyName
    #                     New-AdaptiveFact -Title 'LaunchTime' -Value $EC2Instance.LaunchTime
                        
    #                 } -Separator Medium 
                    
                    
    #             } 
                
    #             New-AdaptiveAction -Title "AWS Details" -Body   {
                    
    #                 New-AdaptiveTextBlock -Text "AWS Details" -Weight Bolder -Size Large -Color Accent # -HorizontalAlignment Center
    #                 New-AdaptiveFactSet {
                        
    #                     New-AdaptiveFact -Title "Function" -Value $LambdaCon.Function
    #                     New-AdaptiveFact -Title 'AWS Account' -Value $AWSAccount
    #                     New-AdaptiveFact -Title 'AvailabilityZone' -Value $EC2Instance.AvailabilityZone
    #                     New-AdaptiveFact -Title "Parameter" -Value $Parameter
    #                     New-AdaptiveFact -Title "LogGroup" -Value $LambdaCon.LogGroup
    #                     New-AdaptiveFact -Title "LogStream" -Value $LambdaCon.LogStream
    #                     New-AdaptiveFact -Title "Time" -Value $LambdaCon.Time
    #                     New-AdaptiveFact -Title "Memory(MB)" -Value $LambdaCon.Memory 
                        
    #                 } -Separator Medium 
                    
    #             }
                
    #         }

    #     }
    # }
    
    # Write-Host "Teams notification sent"
    
    #-----------------------------------------------------------------------------------------------------------------------------------------------
    
}