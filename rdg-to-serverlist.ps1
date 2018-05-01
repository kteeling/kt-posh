$RDCFile = "\\server\share\rdg.rdg" # .rdg file to parse
$servArr = @()
$serverFile = "\\server\share\output.txt" # output file
Remove-Item $serverFile -Confirm
$RDCNames = Get-Content $RDCFile | Where-Object {$_ -like '*<name>*'}
$RDCNames | foreach {
    $line = $_.ToString()
    $serverName = $line.Replace(" ","").Replace("/","").Replace("<name>","")
    $servArr += $serverName
    }
$servArr | 
    Where-Object {$_ -like "*10.*"} | 
    Sort-Object -Unique |
        foreach {
        $addItem = $_
        $addItem | Out-File $serverFile -Append
        }
$servArr | 
    Where-Object {($_ -like "*hqit*" -or $_ -like "*itd*") -and ($_ -notlike "*(*")} | 
    Sort-Object -Unique |
        foreach {
        $addItem = $_+ ".domain" #append domain
        $addItem = $addItem.Replace(".domain.domain",".domain") #remove where domain is doubled
        $addItem | Out-File $serverFile -Append
        }
