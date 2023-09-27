Import-Module AWS.Tools.EC2

$EC2 =  Get-EC2Instance

$Inst = (Get-EC2Instance -Filter @{Name="tag:Name";Values="DBA_TestServer"}).Instances

(Get-EC2Instance -InstanceId $($Inst.InstanceId)).Instances 
$Inst.State.Name.Value