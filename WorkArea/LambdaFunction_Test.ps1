



Get-Command -Module 'AWS.Tools.SimpleSystemsManagement'









$StartupType

# Write-SSMParameter -Name $AWS.StartedParam -Type String -Description $AWS.DescriptionDetails -Value $InstanceID -Overwrite $true
# Write-SSMParameter -Name $AWS.PatchingParam -Type String -Description $AWS.DescriptionDetails -Value $InstanceID -Overwrite $true

Remove-SSMParameter -Name $AWS.StartedParam -Confirm:$false
Remove-SSMParameter -Name $AWS.PatchingParam -Confirm:$false



