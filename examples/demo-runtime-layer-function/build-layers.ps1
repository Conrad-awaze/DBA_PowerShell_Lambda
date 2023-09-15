$ProgressPreference = 'SilentlyContinue'

$examplesPath = Split-Path -Path $PSScriptRoot -Parent
$gitRoot = Split-Path -Path $examplesPath -Parent
$layersRoot = Join-Path -Path $PSScriptRoot -ChildPath 'layers'

####################
# PwshRuntimeLayer #
####################
$runtimeLayerPath = Join-Path -Path $layersRoot -ChildPath 'runtimeLayer'
$runtimeBuildScript = [System.IO.Path]::Combine($gitRoot, 'powershell-runtime', 'build-PwshRuntimeLayer.ps1')
& $runtimeBuildScript -PwshArchitecture 'x64' -LayerPath $runtimeLayerPath

#################
# AWSToolsLayer #
#################
$AWSModules = @('AWS.Tools.Common','AWS.Tools.EC2','AWS.Tools.CloudWatchLogs','AWS.Tools.DynamoDBv2','AWS.Tools.CloudWatch')
$awsToolsLayerPath = Join-Path -Path $layersRoot -ChildPath 'modulesLayer'
$awsToolsBuildScript = [System.IO.Path]::Combine($gitRoot, 'powershell-modules', 'AWSToolsforPowerShell', 'Demo-AWS.Tools', 'build-AWSToolsLayer.ps1')
& $awsToolsBuildScript -ModuleList $AWSModules -LayerPath $awsToolsLayerPath

########################
# SAM Template Updates #
########################
$samTemplatePath = Join-Path -Path $PSScriptRoot -ChildPath 'template.yml'
(Get-Content -Path $samTemplatePath -Raw).replace(
    'ContentUri: ../../powershell-runtime/source', 'ContentUri: ./layers/runtimeLayer').replace(
    'ContentUri: ../../powershell-modules/AWSToolsforPowerShell/Demo-AWS.Tools/buildlayer', 'ContentUri: ./layers/modulesLayer') | Set-Content -Path $samTemplatePath -Encoding ascii
