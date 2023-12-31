Import-Module AWS.Tools.DynamoDBv2
Import-Module AWS.Tools.SimpleSystemsManagement
Import-Module AWS.Tools.EC2
Import-Module AWS.Tools.SecretsManager
Import-Module AWS.Tools.CloudFormation

Update-AWSToolsModule

$AWS = @{

    Hostname            = ($EC2Instance.Name).ToLower()
    # source              = "ec2.events"
    # NameDetails         = "/prod/ILT-Elasticity/Replicated/$($EC2Instance.Name)"
    StartedParam        = "/prod/ILT-Elasticity/Started/$(($EC2Instance.Name).ToLower())"
    OfflineParam        = "/prod/ILT-Elasticity/offline-ilts/$(($EC2Instance.Name).ToLower())"
    StartedforReplParam = "/prod/ILT-Elasticity/StartedforReplicationCatchup/" + ($EC2Instance.Name).ToLower()
    PatchingParam       = "/prod/ILT-Elasticity/Patching/$(($EC2Instance.Name).ToLower())"
    MaintModeParam      = "/prod/ILT-Elasticity/InMaintenanceMode/$(($EC2Instance.Name).ToLower())"
    
}

$Ec2Instance  = "vruka-iltsql08b"
$CurrentParameter = (Get-SSMParameterList).Name | Where-Object  {$_ -match $(($EC2Instance.Name).ToLower())}

if ($CurrentParameter.Count -eq 1) {
    
    switch ($Parameter) {
        {$_ -match 'InMaintenanceMode'} { 
            Write-Host "Maint Mode"
        }
        {$_ -match 'Patching'} { 
            Write-Host "Patching"
        }
        {$_ -match 'Started'} { 
            Write-Host "AutoScaling"
        }
        Default {
            Write-Host "No parameters found"
        }
    }
}else {
    Write-Host "ERROR: More than one paramater found"
    Write-Host "$CurrentParameter"
    exit
}

Install-Module -Name 'AWS.Tools.CloudFormation' -Scope AllUsers
Find-Module -Name Webserver
Get-Command -Module AWS.Tools.CloudFormation

Get-CFNStack -StackName 'aws-sam-cli-managed-default' -AccessKey $KeyA.AccessKey -SecretKey $KeyA.SecretKey -Region eu-west-2

Get-SECSecretList
Get-SECSecret -SecretId 'Conrad-AWS'


$KeyCommon = (Get-SECSecretValue -SecretId 'DBAKeys-Common').SecretString | ConvertFrom-Json
$KeySandpit = (Get-SECSecretValue -SecretId 'DBAKeys-Sandpit').SecretString | ConvertFrom-Json
$KeyA = (Get-SECSecretValue -SecretId 'DBAKeys-VRUK-A').SecretString | ConvertFrom-Json

(Get-EC2Instance -AccessKey $KeyCommon.AccessKey -SecretKey $KeyCommon.SecretKey -Region eu-west-2).Instances 
(Get-EC2Instance -AccessKey $KeySandpit.AccessKey -SecretKey $KeySandpit.SecretKey -Region eu-west-2).Instances

$Instance = (Get-EC2Instance -InstanceId 'i-050bc3b7c1d01f687').Instances | gm
$Instance.CurrentInstanceBootMode
$Instance.Placement.AvailabilityZone
# Set-AWSCredential -AccessKey $Key.AccessKey -SecretKey $Key.SecretKey -Scope Global

Get-DDBTables -AccessKey $KeyCommon.AccessKey -SecretKey $KeyCommon.SecretKey -Region eu-west-2
Get-DDBTables -AccessKey $KeySandpit.AccessKey -SecretKey $KeySandpit.SecretKey -Region eu-west-2

Get-Help Get-SECSecretValue -Examples
(Get-Module -ListAvailable).Name | Sort-Object   | Select-Object -First 40

$TableName = 'DBA-EC2StateMonitor'

# Create KeySchema
$Schema = New-DDBTableSchema
$Schema |   Add-DDBKeySchema -KeyName "PK" -KeyDataType "S" -KeyType HASH | 
            Add-DDBKeySchema -KeyName "SK" -KeyType RANGE -KeyDataType "S" 

# Create New Table
New-DDBTable -TableName $TableName -Schema $Schema -ReadCapacity 10 -WriteCapacity 5

Get-DDBTable -TableName 'DBA-EC2StateMonitor'

$dynamoDBEvent = @{
                
    PK              = "$(Get-Date -format yyyy-MM-dd)"
    SK              = "$(get-date -format "HH:mm")"
    User            = $($env:USERNAME)
    ComputerName    = $($env:COMPUTERNAME)#
    Message         = "Test Message - Time: $(get-date -format "HH:mm:ss")"
    
} | ConvertTo-DDBItem
Set-DDBItem -TableName $TableName -Item $dynamoDBEvent

$invokeDDBQuery = @{
    TableName = $TableName
    ProjectionExpression = "PK, SK,Message"
    KeyConditionExpression = ' PK = :PK and begins_with(SK, :SK)'
    ExpressionAttributeValues = @{
        ':PK' = "$(Get-Date -format yyyy-MM-dd)"
        ':SK' = '1'
    } | ConvertTo-DDBItem
}
$Results = Invoke-DDBQuery @invokeDDBQuery | ConvertFrom-DDBItem
$Results.Count
$Results[0].PK

$key = @{

    PK = "$(Get-Date -format yyyy-MM-dd)"
    SK = "09:45"

} | ConvertTo-DDBItem
Remove-DDBItem -TableName $TableName -Key $key -Confirm:$false

Remove-DDBTable -TableName $TableName -Force -AccessKey $KeyCommon.AccessKey -SecretKey $KeyCommon.SecretKey -Region eu-west-2

# $AWSToolsSource = 'https://sdk-for-net.amazonwebservices.com/ps/v4/latest/AWS.Tools.zip'

# $zipFile = Join-Path -Path 'C:\WorkArea' -ChildPath 'AWS.Tools.zip'

# Invoke-WebRequest -Uri $AWSToolsSource -OutFile $zipFile

# Expand-Archive -Path $zipFile -DestinationPath $ModuleStagingPath -ErrorAction SilentlyContinue

# Import-Module 'C:\WorkArea\AWS.Tools\AWS.Tools.SecretsManager'


$GUID1              = '10ed1b71-1a9f-4427-a5cb-8ffc041487cd@bd846b68-132a-4a46-b1e7-d090e168c0a2'
$GUID2              = '6eda4df9f3a246c582a0362c83e0ec58/34d83ea3-495b-45f0-9efa-2a30f32d086e'
$URI                = "https://awazecom.webhook.office.com/webhookb2/$GUID1/IncomingWebhook/$GUID2"

New-AdaptiveCard -Uri $URI -VerticalContentAlignment center -FullWidth  {
    New-AdaptiveContainer {

        New-AdaptiveTextBlock -Size Large -Weight Bolder -Text "Server - No parameters found. Manual Start Up" -Color Accent -HorizontalAlignment Center

        New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None -Color Good
        New-AdaptiveFactSet {
    
            New-AdaptiveFact -Title 'Server State' -Value 'RUNNING'
            
        } -Separator Medium
        
    }
}