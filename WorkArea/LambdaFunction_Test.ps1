Remove-Module 'AWS.Tools.EC2','AWS.Tools.SimpleSystemsManagement','AWS.Tools.Common'
Import-Module 'AWS.Tools.EC2'
Import-Module 'AWS.Tools.SimpleSystemsManagement'

# https://docs.aws.amazon.com/powershell/latest/reference/items/Get-EC2Instance.html

$InstancesRunning = (Get-EC2Instance -Filter @{Name = "tag:Name"; Values = "VRUK-*"},@{Name = "instance-state-name"; Values = "running"}).Instances
$InstancesStopped = (Get-EC2Instance -Filter @{Name = "tag:Name"; Values = "VRUK-*"},@{Name = "instance-state-name"; Values = "stopped"}).Instances


$Instances.State
$InstanceIDs = (Get-EC2Instance).Instances.InstanceID

foreach ($ID in $InstanceIDs) {

    $EC2    =  (Get-EC2Instance -InstanceId $ID).Instances
    Write-Host "$(($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value)"

}


Get-Command -Module 'AWS.Tools.SimpleSystemsManagement'

$EC2Instance = 'VRUK-A-ILTSQL30'

$AWS = @{

    Hostname            = ($EC2Instance).ToLower()
    StartedParam        = "/prod/ILT-Elasticity/Started/$(($EC2Instance).ToLower())"
    OfflineParam        = "/prod/ILT-Elasticity/offline-ilts/$(($EC2Instance).ToLower())"
    PatchingParam       = "/prod/ILT-Elasticity/Patching/$(($EC2Instance).ToLower())"
    DescriptionDetails  = "Replication is now completed on $($EC2Instance). This Parameter will be deleted by ILT-Elasticity once the server has been added to the ILT Target Group"
    OfflineDescr        = "Replication is now completed on $($EC2Instance) and the server has been shutdown. This Parameter will be deleted by ILT-Elasticity once the server has been brought up once again"
}

Write-SSMParameter -Name $AWS.StartedParam -Type String -Description $AWS.DescriptionDetails -Value $InstanceID -Overwrite $true
Write-SSMParameter -Name $AWS.PatchingParam -Type String -Description $AWS.DescriptionDetails -Value $InstanceID -Overwrite $true

Remove-SSMParameter -Name $AWS.StartedParam -Confirm:$false
Remove-SSMParameter -Name $AWS.PatchingParam -Confirm:$false

$EC2            =  (Get-EC2Instance -InstanceId $InstanceID).Instances
($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value

$EC2.Tags


$ParameterList = (Get-SSMParameterList).Name
$ParameterList
Get-Command -Module 'AWS.Tools.SimpleSystemsManagement'
Get-Command -Module 'AWS.Tools.EC2'

Get-Help Get-EC2Instance -Examples
 

Get-EC2Tag -Filter @{Name="Key";Value="VRUK-A-ILTSQL31"} 





