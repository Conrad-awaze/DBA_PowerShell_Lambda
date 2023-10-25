Import-Module AWS.Tools.DynamoDBv2
Import-Module 'AWS.Tools.SimpleSystemsManagement'
Import-Module AWS.Tools.EC2

Get-Command -Module AWS.Tools.EC2
Get-EC2Instance


(Get-SSMParameterList).Name

Get-Command -Module AWS.Tools.DynamoDBv2

Get-DDBTables

Get-DDBTable -TableName DBA_EC2StateMonitor


$TableName = 'DBA-TestTable'

# Create KeySchema
$Schema = New-DDBTableSchema
$Schema |   Add-DDBKeySchema -KeyName "PK" -KeyDataType "S" -KeyType HASH | 
            Add-DDBKeySchema -KeyName "SK" -KeyType RANGE -KeyDataType "S" 

# Create New Table
New-DDBTable -TableName $TableName -Schema $Schema -ReadCapacity 5 -WriteCapacity 5

Remove-DDBTable -TableName $TableName -Force