Import-Module AWS.Tools.DynamoDBv2, AWS.Tools.EC2


$InstanceID     =  'i-0b8ba7a0d4f6a1608'
$EC2            =  (Get-EC2Instance -InstanceId $InstanceID).Instances
($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq state).Value
$EC2 | Get-Member
$EC2.Tags

$EC2Instance    = [PSCustomObject]@{

    Name        = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Name).Value
    Owner       = ($EC2 | Select-Object -ExpandProperty Tags | Where-Object -Property Key -eq Owner).Value
    State       = $EC2.State.Name.Value.ToUpper()
    Type        = $EC2.InstanceType.Value
    InstanceId  = $EC2.InstanceId
    KeyName     = $EC2.KeyName
    LaunchTime  = $EC2.LaunchTime
}

$EC2Instance

Get-Command -Module AWS.Tools.DynamoDBv2

Get-Help New-DDBTable -Examples

$TableName = 'EC2StateChangeLogs'
# Get current list of tables
$TableList  = Get-DDBTables

if ($TableList -contains $TableName) {
    Write-Host "DynamoDB - Table [$TableName] already exists"
}
else {

    Write-Host "DynamoDB - Creating table - [$TableName]...!!!!"

    # Create KeySchema
    $Schema = New-DDBTableSchema
    $Schema |   Add-DDBKeySchema -KeyName "PK" -KeyDataType "S" -KeyType HASH | 
                Add-DDBKeySchema -KeyName "SK" -KeyType RANGE -KeyDataType "S" 

    # Creat New Table
    $TableDetails = New-DDBTable -TableName $TableName -Schema $Schema -ReadCapacity 5 -WriteCapacity 5

    # Confirm Table is active
    while ((Get-DDBTable -TableName $TableName).TableStatus.Value -ne 'Active') {

        Start-Sleep 5
        $TableStatus = (Get-DDBTable -TableName $TableName).TableStatus.Value
    
        switch ($TableStatus) {
            Active { Write-Host "DynamoDB - Table Status - $TableStatus" }
            Default {Write-Host "DynamoDB - Table Status - $TableStatus"}
        }
    }
}
