Import-Module AWS.Tools.EC2
Import-Module AWS.Tools.Lambda
Import-Module AWS.Tools.CloudWatchLogs

Get-Command -Module AWS.Tools.CloudWatchLogs

$EC2InstanceName    = 'DBA_Server'
$Instance           = (Get-EC2Instance -Filter @{Name = "tag:Name"; Values= $EC2InstanceName}).Instances

$Instance.Tags
$Instance.State.Name.Value
$Instance.InstanceId
$Instance.State 


Get-Command -Module AWS.Tools.Lambda

Get-Help Get-LMFunctionList  -Examples
Get-Help Invoke-LMFunction  -Examples

$Function = Get-LMFunction -FunctionName 'DBATestFunction'

# $AWS = @{

#     Hostname            = ($env:COMPUTERNAME).ToUpper()
    
# }
# $AWSPayload = $AWS | ConvertTo-Json
# $AWSPayload

# $Response = Invoke-LMFunction -FunctionName 'DBATestFunction' -Payload $AWSPayload
# $Response.StatusCode

