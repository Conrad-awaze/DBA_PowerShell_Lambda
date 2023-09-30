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


$Name   = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value
$Owner  =  ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Owner).Value

$EC2Instance = [PSCustomObject]@{

    Name        = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value
    $Owner      = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Owner).Value
    State       = $($EC2.State.Name.Value.ToUpper())
    Type        = $EC2.InstanceType.Value
    InstanceId  = $EC2.InstanceId
    KeyName     = $EC2.KeyName
    LaunchTime  = $EC2.LaunchTime
}

$EC2.PublicDnsName | gm