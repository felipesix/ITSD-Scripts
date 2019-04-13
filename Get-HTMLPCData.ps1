Function Get-HTMLPCRamUsage {
    
    Begin{        
        
        $Ram = Get-WmiObject -class Win32_OperatingSystem                
        $Css = 'C:\htmlpcramusage.css'
        
        $Properties = @(        
            
            'Computer',
            'TotalRam',
            'FreeRam',
            @{
                Name = 'FreeRam(%)'; Expression = {$_.FreePercentageRam}
                Css = {                 
                    If ($_.FreePercentageRam -gt 50) {'Green'}
                    ElseIF ($_.FreePercentageRam -gt 25) {'Yellow'}
                    Else{'Red'}
                }
            }
        )        
    }
    
    Process {        
    
        # TotalRam     
        [int]$TotalRam = ($ram.TotalVisibleMemorySize / 1mb)

        # FreeRam    
        $RamFree = [math]::Round($ram.FreePhysicalMemory / 1mb,1)

        # Free Percentage        
        $RamFP = "{0:P0}" -f ($ram.FreePhysicalMemory / $ram.TotalVisibleMemorySize)

        # Table
        $Table = [PSCustomObject]@{        
            
            Computer = $(hostname)
            TotalRam = "$TotalRam GB"                
            FreeRam = "$RamFree GB"
            FreePercentageRam = $RAMFP
        }                    
        
        # HTML Fragment
        $params = @{
            
            As = 'List'
            PreContent = "<h2>FELIPE-PC</h2>"
            MakeTableDynamic = $true
            MakeHiddenSection = $true
            TableCssClass = 'List'
            Properties = $Properties
        }        

        $Frag = $Table | ConvertTo-EnhancedHTMLFragment @params   

        # HTML Build
        $HTMLParams = @{
            Title = 'Monitor RAM Usage'
            HTMLFragments = $Frag
            CssUri = $Css
        } 
    }

    End {
    
        $HTML = ConvertTo-EnhancedHTML @HTMLParams
        $HTML | Out-File c:\PCData.html -Force
        Invoke-Item c:\PCDATA.html
    }
}