$ProgressPreference = 'SilentlyContinue'

$examplesPath   = Split-Path -Path $PSScriptRoot -Parent
$gitRoot        = Split-Path -Path $examplesPath -Parent
$layersRoot     = Join-Path -Path $PSScriptRoot -ChildPath 'layers'

####################
# PwshRuntimeLayer #
####################
$runtimeLayerPath   = Join-Path -Path $layersRoot -ChildPath 'runtimeLayer'
$runtimeBuildScript = [System.IO.Path]::Combine($gitRoot, 'powershell-runtime', 'build-PwshRuntimeLayer.ps1')
& $runtimeBuildScript -PwshArchitecture 'x64' -LayerPath $runtimeLayerPath