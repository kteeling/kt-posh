cls
$serverFile = "\\server\share\input.txt" # input list of servers
$servers = Get-Content $serverFile
$resultsFile = "\\server\share\results.csv" # output CSV
remove-item $resultsFile -Confirm
Foreach ($server in $servers) {
    $certArrAll = @()
    $certArrS = Invoke-Command -ComputerName $server -ScriptBlock {
        $certificates = Get-ChildItem -Path CERT:LocalMachine\My
        $today = Get-Date
        $certArr=@()
        foreach ($cert in $certificates) {
            $expDays = (($cert.NotAfter - $today).Days).ToString()
            $expDate = ($cert.NotAfter).ToString("yyyy-MM-dd")
            $certHost = (($cert.Subject.Split(',')[0]).TrimStart('CN=')).ToString()
            $certServer = ($env:computername).ToString()
            $certObjA = [PSCustomObject]@{
                Server = $certServer
                CertDNS = $certHost
                NotAfter = $expDate
                ExpireInDays = $expDays
                }
            $certArr += $certObjA
            }
        $certArr
        }
$i=0
Do {
    $certArrSV = ($certArrS[$i].GetEnumerator() | Select-Object -ExpandProperty Value)
    $certObjB = [PSCustomObject]@{
        Server = $certArrSV[0]
        CertDNS = $certArrSV[2]
        NotAfter = $certArrSV[3]
        ExpireInDays = $certArrSV[1]
        } 
    Export-Csv -InputObject $certObjB -LiteralPath $resultsFile -NoTypeInformation -Append
    $i++
    }
    While ($i -lt $certArrS.Count)
}
