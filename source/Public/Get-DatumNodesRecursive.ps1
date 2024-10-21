using module datum

function Get-DatumNodesRecursive
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [object]
        $AllDatumNodes = (Get-Variable -Name Datum -ValueOnly).AllNodes
    )

    $datumContainers = [System.Collections.Queue]::new()

    Write-Verbose -Message "Inspecting [$($AllDatumNodes.PSObject.Properties.Where({$_.MemberType -eq 'NoteProperty'}).Name -join ', ')]"
    foreach ($property in $AllDatumNodes.PSObject.Properties.Where({ $_.MemberType -eq 'NoteProperty' }))
    {
        Write-Verbose -Message "Working on '$($property.Name)'."
        $val = $property.Value | Add-Member -MemberType NoteProperty -Name Name -Value $property.Name -PassThru -ErrorAction Ignore -Force
        if ($val -is [FileProvider])
        {
            Write-Verbose -Message "Adding '$($val.Name)' to the queue."
            $datumContainers.Enqueue($val)
        }
        else
        {
            Write-Verbose -Message "Adding Node '$($property.Name)'."
            $val['Name'] = $property.Name
            $val
        }
    }

    while ($datumContainers.Count -gt 0)
    {
        $currentContainer = $datumContainers.Dequeue()
        Write-Debug -Message "Working on Container '$($currentContainer.Name)'."

        foreach ($property in $currentContainer.PSObject.Properties.Where({ $_.MemberType -eq 'NoteProperty' }))
        {
            $val = $currentContainer.($property.Name)

            if ($val -isnot [System.Collections.Hashtable] -and $val -isnot [System.Collections.Specialized.OrderedDictionary])
            {
                continue
            }

            $val | Add-Member -MemberType NoteProperty -Name Name -Value $property.Name -ErrorAction Ignore
            if ($val -is [FileProvider])
            {
                Write-Verbose -Message "Found Container '$($property.Name).'"
                $datumContainers.Enqueue($val)
            }
            else
            {
                Write-Verbose -Message "Found Node '$($property.Name)'."
                $val['Name'] = $property.Name
                $val
            }
        }
    }
}
