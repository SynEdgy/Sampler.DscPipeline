using module datum

function Get-DatumNodesRecursive
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [object]
        $AllDatumNodes = (Get-variable -Name Datum -scope 1 -ValueOnly).AllNodes
    )

    $datumContainers = [System.Collections.Queue]::new()
    
    Write-Verbose -Message "Inspecting [$($AllDatumNodes.Name -join ', ')]"
    $AllDatumNodes.PSObject.Properties.Where({$_.MemberType -eq 'ScriptProperty'}).ForEach({
        Write-Verbose -Message "Working on $($_.Name)"
        $val = $_.Value | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -PassThru -ErrorAction Ignore -Force
        if ($val -is [FileProvider])
        {
            Write-Verbose -Message "Adding $($val.Name) to the queue."
            $datumContainers.Enqueue($val)
        }
        else
        {
            Write-Verbose -Message "Adding Node $($_.Name)."
            $val['Name'] = $_.Name
            $val
        }
    })

    while ($datumContainers.Count -gt 0)
    {
        $currentContainer = $datumContainers.Dequeue()
        Write-Verbose -Message "Working on Container '$($currentContainer.Name)'."
        
        $currentContainer.PSObject.Properties.Where({$_.MemberType -eq 'ScriptProperty'}).ForEach({
            $val = $currentContainer.($_.Name)
            $val | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -ErrorAction Ignore
            if ($val -is [FileProvider])
            {
                Write-Verbose -Message "Found Container $($_.Name)"                
                $datumContainers.Enqueue($val)
            }
            else
            {
                Write-Verbose -Message "Found Node $($_.Name)"                
                $val
            }
        })
    }
}
