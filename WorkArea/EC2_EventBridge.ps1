Import-Module AWS.Tools.EC2

$Instances =  Get-EC2Instance
$Instances.Instances
$Instances.Instances | Where-Object {$_.Tags.Name -eq 'DBA_TestServer'}

Get-Help Get-EC2Instance -Examples

$Inst = (Get-EC2Instance -Filter @{Name="tag:Name";Values="DBA_TestServer"}).Instances

(Get-EC2Instance -InstanceId $($Inst.InstanceId)).Instances 
$Inst.State.Name.Value