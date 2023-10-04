
Get-Command -Module 'AWS.Tools.SimpleSystemsManagement'

$InstanceID  =  'i-0b8ba7a0d4f6a1608'
$EC2            =  (Get-EC2Instance -InstanceId $InstanceID).Instances
($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq state).Value
$EC2 | Get-Member
$EC2.Tags

$EC2Instance = 'VRUK-A-ILTSQL30'

$AWS = @{

    # InstanceID          = get-ec2instancemetadata -Category instanceid
    Hostname            = ($EC2Instance).ToLower()
    # source              = "ec2.events"
    # NameDetails         = "/prod/ILT-Elasticity/Replicated/$($EC2Instance)"
    StartedParam        = "/prod/ILT-Elasticity/Started/$(($EC2Instance).ToLower())"
    OfflineParam        = "/prod/ILT-Elasticity/offline-ilts/$(($EC2Instance).ToLower())"
    StartedforReplParam = "/prod/ILT-Elasticity/StartedforReplicationCatchup/" + ($EC2Instance).ToLower()
    PatchingParam       = "/prod/ILT-Elasticity/Patching/$(($EC2Instance).ToLower())"
    DescriptionDetails  = "Replication is now completed on $($EC2Instance). This Parameter will be deleted by ILT-Elasticity once the server has been added to the ILT Target Group"
    OfflineDescr        = "Replication is now completed on $($EC2Instance) and the server has been shutdown. This Parameter will be deleted by ILT-Elasticity once the server has been brought up once again"
}


$ParameterList = (Get-SSMParameterList).Name
$ParameterList
# Write-SSMParameter -Name $AWS.StartedParam -Type String -Description $AWS.DescriptionDetails -Value $InstanceID -Overwrite $true
# Write-SSMParameter -Name $AWS.PatchingParam -Type String -Description $AWS.DescriptionDetails -Value $InstanceID -Overwrite $true

Remove-SSMParameter -Name $AWS.StartedParam -Confirm:$false
Remove-SSMParameter -Name $AWS.PatchingParam -Confirm:$false





