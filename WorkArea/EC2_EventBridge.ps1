Import-Module AWS.Tools.EC2
Import-Module AWS.Tools.SimpleSystemsManagement
Import-Module AWS.Tools.Lambda
Import-Module AWS.Tools.CloudWatchLogs
Import-Module AWS.Tools.RDS
Import-Module AWS.Tools.DynamoDBv2


Find-Module -Name 'AWS.Tools*'
Install-Module AWS.Tools.Lambda -Scope AllUsers -Force

$EC2InstanceName    = 'VRUK-A-ILTSQL30'
$EC2 = (Get-EC2Instance -Filter @{Name = "tag:Name"; Values= $EC2InstanceName}).Instances

$AWS = @{

    InstanceID          = $EC2.InstanceId
    Hostname            = ($EC2InstanceName).ToLower()
    NameDetails         = "/prod/ILT-Elasticity/Replicated/$($EC2InstanceName)"
    StartedParam        = "/prod/ILT-Elasticity/Started/$(($EC2InstanceName).ToLower())"
    OfflineParam        = "/prod/ILT-Elasticity/offline-ilts/$(($EC2InstanceName).ToLower())"
    PatchingParam       = "/prod/ILT-Elasticity/Patching/$(($EC2InstanceName).ToLower())"
    DescriptionDetails  = "Replication is now completed on $($EC2InstanceName). This Parameter will be deleted by ILT-Elasticity once the server has been added to the ILT Target Group"
    OfflineDescr        = "Replication is now completed on $($EC2InstanceName) and the server has been shutdown. This Parameter will be deleted by ILT-Elasticity once the server has been brought up once again"
}
(Get-SSMParameterList).Name
Get-SSMParameter -Name 'AmazonCloudWatch-Windows'
Get-SSMParameter -Name $AWS.StartedParam


$Parameter = Get-SSMParameter -Name $AWS.StartedParam
$Parameter.Name 

Remove-SSMParameter -Name $AWS.StartedParam -Force
Write-Host "AWS Started Parameter Deleted - $($AWS.StartedParam)"

#--------------------------------------------------------------------------------------------------------------------------------------------
#AWS Update - Create a new parameter confirming replication has completed 

Write-SSMParameter -Name $AWS.StartedParam -Type String -Description $AWS.DescriptionDetails -Value $AWS.InstanceID -Overwrite $true
Write-Host "AWS Replication Parameter Created $($AWS.NameDetails)"

Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="key";Values="Name"}

(Get-EC2Instance).Instances
(Get-EC2Instance -Filter @{Name = "tag:Name"; Values= 'VRUK-A-ILTSQL30'}).Instances



$Instance = (Get-EC2Instance -Filter @{Name = "tag:Name"; Values= $EC2InstanceName}).Instances

switch ($Instance.State.Name.Value) {
    running { 
        Stop-EC2Instance -InstanceId $Instance.InstanceId 
        Write-Host "[$EC2InstanceName] Server State - $($PSItem.ToUpper()) - Stopped Instance"
    }
    stopped { 
        Start-EC2Instance -InstanceId $Instance.InstanceId 
        Write-Host "[$EC2InstanceName] Server State - $($PSItem.ToUpper()) - Started Instance"
    }
    Default { 
        Write-Host "[$EC2InstanceName] Server State - $($PSItem.ToUpper())"
    }
}

Get-EC2Tag -Filter @{Name="resource-type";Values="instance"},@{Name="key";Values="Name"} | 
    Select-Object ResourceId, @{Name="Name-Tag";Expression={$PSItem.Value}} | Format-Table -AutoSize

$Instance.Tags
$Instance.State.Name.Value
$Instance.InstanceId
$Instance.State 


Get-LMFunctionList

Get-LMFunction -FunctionName 'DBA_SSRS-Send-Teams-Notifications' 
Get-LMFunction -FunctionName 'DBA_EC2-State-Change-Monitor'
Get-LMFunction -FunctionName 'PowerShell-Lambda-V2-PowerShellFunction-wORwyRR42suS'


Get-Command -Module AWS.Tools.Lambda -Verb Get

Get-Help Get-LMFunction -Examples
Get-Help Invoke-LMFunction  -Examples

$Function = Get-LMFunction -FunctionName 'DBATestFunction'

Get-LMFunctionList

Get-Command -Module AWS.Tools.DynamoDBv2

Get-DDBTableList
Get-DDBTable -TableName DBA_EC2StateMonitor
Get-DDBTable -TableName TestTable

