$ProgressPreference = 'SilentlyContinue'

# $examplesPath   = Split-Path -Path $PSScriptRoot -Parent
$layersRoot     = Join-Path -Path $PSScriptRoot -ChildPath 'layers'

####################
# PwshRuntimeLayer #
####################
$runtimeLayerPath   = Join-Path -Path $layersRoot -ChildPath 'runtimeLayer'
$runtimeBuildScript = [System.IO.Path]::Combine('powershell-runtime', 'build-PwshRuntimeLayer.ps1')
& $runtimeBuildScript -PwshArchitecture 'x64' -LayerPath $runtimeLayerPath

#################
# AWSToolsLayer #
#################
$AWS_Modules = @(

    'AWS.Tools.Common','AWS.Tools.AutoScaling','AWS.Tools.CloudFormation','AWS.Tools.CloudWatch',
    'AWS.Tools.CloudWatchLogs','AWS.Tools.DynamoDBv2','AWS.Tools.EBS','AWS.Tools.EC2','AWS.Tools.EventBridge',
    'AWS.Tools.ElasticLoadBalancing','AWS.Tools.Lambda','AWS.Tools.S3','AWS.Tools.SQS'
)
$awsToolsLayerPath = Join-Path -Path $layersRoot -ChildPath 'modulesLayer'
$awsToolsBuildScript = [System.IO.Path]::Combine('powershell-modules', 'AWSToolsforPowerShell', 'build-AWSToolsLayer.ps1')
& $awsToolsBuildScript -ModuleList $AWS_Modules -LayerPath $awsToolsLayerPath

########################
# SAM Template Updates #
########################
$samTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath 'template.yml'
(Get-Content -Path $samTemplatePath -Raw).replace(
    'ContentUri: ../../powershell-runtime/source', 'ContentUri: ./layers/runtimeLayer').replace(
    'ContentUri: ../../powershell-modules/AWSToolsforPowerShell/Demo-AWS.Tools/buildlayer', 'ContentUri: ./layers/modulesLayer') | 
    Set-Content -Path $samTemplatePath -Encoding ascii
