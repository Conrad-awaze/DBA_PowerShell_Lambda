Write-Host "Importing Modules"
Import-Module "AWS.Tools.Common",'PSTeams'

function handler
{
    [cmdletbinding()]
    param(
        [parameter()]
        $LambdaInput,

        [parameter()]
        $LambdaContext
        
    )
    
    $LambdaCon      = [PSCustomObject]@{

        LogStream   = $LambdaContext.LogStreamName
        LogGroup    = $LambdaContext.LogGroupName
        Function    = $LambdaContext.FunctionName
        Memory      = $LambdaContext.MemoryLimitInMB

    }
    
    switch ($LambdaInput.Status) {
        Started { 
            
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

            New-AdaptiveCard -Uri "$($LambdaInput.URI)" -VerticalContentAlignment center -FullWidth  {
            New-AdaptiveContainer {
        
                New-AdaptiveTextBlock -Text "SSRS Refresh Started" -Size ExtraLarge -Wrap -HorizontalAlignment Center -Color Accent
                New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None
                New-AdaptiveTextBlock -Text "$($LambdaInput.Environment)" -Subtle -HorizontalAlignment Center -Color Good -Size Large -Spacing None
                    
                }
            } -Action {
                New-AdaptiveAction -Title "Refresh Parameters" -Body   {
                    New-AdaptiveTextBlock -Text "SSRS Refresh Parameters" -Weight Default -Size Large -Color Accent -HorizontalAlignment Left
                    New-AdaptiveFactSet {
            
                        New-AdaptiveFact -Title 'Environment' -Value "$($LambdaInput.Environment)"
                        New-AdaptiveFact -Title 'Root Folder' -Value "$($LambdaInput.BreaseRootFolder)"
                        New-AdaptiveFact -Title 'DataSource Folder' -Value "$($LambdaInput.DataSourceFolder)"
                        
                    } -Separator Medium
                }
                New-AdaptiveAction -Title "Lambda Details" -Body   {
                    
                    New-AdaptiveTextBlock -Text "Lambda Details" -Weight Bolder -Size Large -Color Accent # -HorizontalAlignment Center
                    New-AdaptiveFactSet {
                        
                        New-AdaptiveFact -Title "Function" -Value $LambdaCon.Function
                        New-AdaptiveFact -Title "LogGroup" -Value $LambdaCon.LogGroup
                        New-AdaptiveFact -Title "LogStream" -Value $LambdaCon.LogStream
                        New-AdaptiveFact -Title "Memory(MB)" -Value $LambdaCon.Memory 
                        
                    } -Separator Medium 
                    
                }
                    
            }
            
        }
        Summary {
            
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

            New-AdaptiveCard -Uri "$($LambdaInput.URI)" -VerticalContentAlignment center -FullWidth  {
            New-AdaptiveContainer {
        
                New-AdaptiveTextBlock -Text "SSRS Refresh Completed" -Size ExtraLarge -Wrap -HorizontalAlignment Center -Color Accent
                New-AdaptiveTextBlock -Text "$(get-date -format "dddd, dd MMMM yyyy HH:mm:ss")" -Subtle -HorizontalAlignment Center -Spacing None
                New-AdaptiveTextBlock -Text "$($LambdaInput.Environment)" -Subtle -HorizontalAlignment Center -Color Good -Size Large -Spacing None
                    
                }
            } -Action {
                New-AdaptiveAction -Title "Refresh Summary" -Body   {
                New-AdaptiveTextBlock -Text "Summary Details" -Weight Default -Size Large -Color Accent -HorizontalAlignment Left
                New-AdaptiveFactSet {
                    
                    New-AdaptiveFact -Title 'Duration' -Value "$($LambdaInput.DurationComplete)"
                    New-AdaptiveFact -Title 'Environment' -Value "$($LambdaInput.Environment)"
                    New-AdaptiveFact -Title 'Selector Reports' -Value "Reports published - $($LambdaInput.PublishedSelectorReports.Count)"
                    New-AdaptiveFact -Title 'Detail Reports' -Value "Reports published - $($LambdaInput.PublishedDetailReports.Count)"
                    New-AdaptiveFact -Title 'DataSource' -Value "$($LambdaInput.DataSourceFolder)"
                    
                } -Separator Medium
                New-AdaptiveTextBlock -Text "Refresh Parameters" -Weight Default -Size Large -Color Accent -HorizontalAlignment Left
                New-AdaptiveFactSet {
                    
                    New-AdaptiveFact -Title 'Root Folder' -Value "$($LambdaInput.BreaseRootFolder)"
                    New-AdaptiveFact -Title 'DataSource' -Value "$($LambdaInput.DataSourceFolder)"
                    
                    
                } -Separator Medium
                }
                New-AdaptiveAction -Title "Lambda Details" -Body   {
                    
                    New-AdaptiveTextBlock -Text "Lambda Details" -Weight Bolder -Size Large -Color Accent # -HorizontalAlignment Center
                    New-AdaptiveFactSet {
                        
                        New-AdaptiveFact -Title "Function" -Value $LambdaCon.Function
                        New-AdaptiveFact -Title "LogGroup" -Value $LambdaCon.LogGroup
                        New-AdaptiveFact -Title "LogStream" -Value $LambdaCon.LogStream
                        New-AdaptiveFact -Title "Memory(MB)" -Value $LambdaCon.Memory 
                        
                    } -Separator Medium 
                    
                }
                    
            }
            
        }
    }
    
    Write-Host "Teams Notification Sent"
    
}