param (

[string]$LogEvent = 'Test message',
[string]$LogGroup = '/awsDBALogs/TestGroup',
[string]$LogStream = "$(get-date -format "yyyy-MM-dd HH-mm") - Test Stream"

)
$LogStream.GetType()
#---------------------------------------------------------------------------------------------------------------------------------------------------
# Check and Create Log Group and Stream

if (!(Get-CWLLogGroup -LogGroupNamePrefix $LogGroup)) {

New-CWLLogGroup -LogGroupName $LogGroup
Write-Host "LogGroup Created - [$LogGroup]"
}

if (!(Get-CWLLogStream -LogGroupName $LogGroup -LogStreamNamePrefix $LogStream)) {

New-CWLLogStream -LogGroupName $LogGroup -LogStreamName $LogStream
Write-Host "LogStream Created - [$LogStream]"
}

$CWEvent = [Amazon.CloudWatchLogs.Model.InputLogEvent]::new()
$CWEvent.Timestamp  = Get-Date
$CWEvent.Message    = $LogEvent

Write-CWLLogEvent -LogGroupName $LogGroup -LogStreamName $LogStream -LogEvent $CWEvent

$Resources = 'arn:aws:ec2:eu-west-2:587525780573:instance/i-0b8ba7a0d4f6a1608'
$InstanceID = ([regex]::Matches($Resources, '\w+\W+\w+$')).Value

$EC2 =  (Get-EC2Instance -InstanceId $InstanceID).Instances
($EC2.InstanceType).Value
$EC2.State.Name.Value.ToUpper()