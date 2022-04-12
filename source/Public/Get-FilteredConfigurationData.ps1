function Get-FilteredConfigurationData
{
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter()]
        [ScriptBlock]
        $Filter = {},

        [Parameter()]
        [int]
        $CurrentJobNumber = 1,

        [Parameter()]
        [int]
        $TotalJobCount = 1,

        [Parameter()]
        [Object]
        $Datum = $(Get-Variable -Name Datum -ValueOnly -ErrorAction Stop)
    )

    if ($null -eq $Filter)
    {
        $Filter = {}
    }

    try
    {
        $allDatumNodes = [System.Collections.Hashtable[]]@(Get-DatumNodesRecursive -AllDatumNodes $Datum.AllNodes -ErrorAction Stop)
    }
    catch
    {
        Write-Error -Message "Could not get datum nodes. Pretty likely there is a syntax error in one of the node's yaml definitions." -Exception $_.Exception
    }
    $totalNodeCount = $allDatumNodes.Count

    Write-Verbose -Message "Node count: $($allDatumNodes.Count)"

    if ($Filter.ToString() -ne {}.ToString())
    {
        Write-Verbose -Message "Filter: $($Filter.ToString())"
        $allDatumNodes = [System.Collections.Hashtable[]]$allDatumNodes.Where($Filter)
        Write-Verbose -Message "Node count after applying filter: $($allDatumNodes.Count)"
    }

    if (-not $allDatumNodes.Count)
    {
        Write-Error -Message "No node data found. There are in total $totalNodeCount nodes defined, but no node was selected. You may want to verify the filter: '$Filter'."
    }

    $CurrentJobNumber--
    $allDatumNodes = Split-Array -List $allDatumNodes -ChunkCount $TotalJobCount
    $allDatumNodes = $allDatumNodes[$CurrentJobNumber]

    return @{
        AllNodes = $allDatumNodes
        Datum    = $Datum
    }
}
