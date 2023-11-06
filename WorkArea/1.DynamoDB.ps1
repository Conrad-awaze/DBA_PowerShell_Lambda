Import-Module AWS.Tools.DynamoDBv2
Import-Module 'AWS.Tools.SimpleSystemsManagement'
Import-Module AWS.Tools.EC2
Import-Module 'AWS.Tools.SecretsManager'


Get-Command -Module AWS.Tools.SecretsManager

Get-SECSecretList
Get-SECSecret -SecretId 'Conrad-AWS'

$Key = (Get-SECSecretValue -SecretId 'DBAKeys-Common').SecretString | ConvertFrom-Json
$Key.AccessKey 

Get-DDBTables 

Get-Help Get-SECSecretValue -Examples
(Get-Module -ListAvailable).Name | Sort-Object   | Select-Object -First 40

$TableName = 'DBA-EC2StateMonitor'

# Create KeySchema
$Schema = New-DDBTableSchema
$Schema |   Add-DDBKeySchema -KeyName "PK" -KeyDataType "S" -KeyType HASH | 
            Add-DDBKeySchema -KeyName "SK" -KeyType RANGE -KeyDataType "S" 

# Create New Table
New-DDBTable -TableName $TableName -Schema $Schema -ReadCapacity 10 -WriteCapacity 5

Get-DDBTable -TableName 'DBA-EC2StateMonitor'

$dynamoDBEvent = @{
                
    PK              = "$(Get-Date -format yyyy-MM-dd)"
    SK              = "$(get-date -format "HH:mm")"
    User            = $($env:USERNAME)
    ComputerName    = $($env:COMPUTERNAME)#
    Message         = "Test Message - Time: $(get-date -format "HH:mm:ss")"
    
} | ConvertTo-DDBItem
Set-DDBItem -TableName $TableName -Item $dynamoDBEvent

$invokeDDBQuery = @{
    TableName = $TableName
    ProjectionExpression = "PK, SK,Message"
    KeyConditionExpression = ' PK = :PK and begins_with(SK, :SK)'
    ExpressionAttributeValues = @{
        ':PK' = "$(Get-Date -format yyyy-MM-dd)"
        ':SK' = '1'
    } | ConvertTo-DDBItem
}
$Results = Invoke-DDBQuery @invokeDDBQuery | ConvertFrom-DDBItem
$Results.Count
$Results[0].PK

$key = @{

    PK = "$(Get-Date -format yyyy-MM-dd)"
    SK = "12:36"

} | ConvertTo-DDBItem
Remove-DDBItem -TableName $TableName -Key $key -Confirm:$false

# Remove-DDBTable -TableName $TableName -Force


# $AWSToolsSource = 'https://sdk-for-net.amazonwebservices.com/ps/v4/latest/AWS.Tools.zip'

# $zipFile = Join-Path -Path 'C:\WorkArea' -ChildPath 'AWS.Tools.zip'

# Invoke-WebRequest -Uri $AWSToolsSource -OutFile $zipFile

# Expand-Archive -Path $zipFile -DestinationPath $ModuleStagingPath -ErrorAction SilentlyContinue

# Import-Module 'C:\WorkArea\AWS.Tools\AWS.Tools.SecretsManager'

