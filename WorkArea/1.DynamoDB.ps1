Import-Module AWS.Tools.DynamoDBv2

Get-Command -Module AWS.Tools.DynamoDBv2

Get-DDBTable -TableName DBA_EC2StateMonitor
Get-DDBTable -TableName TestTable

Get-DDBTableList