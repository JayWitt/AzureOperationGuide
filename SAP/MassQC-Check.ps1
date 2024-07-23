$VMStatus = @()

$FolderPath = "<<Insert Folder Path Here>>"

$folder = Get-childItem -Path $FolderPath -Filter "*.html"

foreach ($File in $folder)
{
    $Source = Get-Content -Path $file.FullName -Raw

    $IssueFound = $false

    write-host -ForegroundColor Blue "Processing $($File.FullName)"
    $HTML = New-Object -Com "HTMLFile"


    $HTML.write([ref]$Source)

    $CreationDate = $html.getElementById("CreationDate").innerhtml
    $scriptVersion = $html.getElementsByTagName("P")[1].innerHTML

    #Get VM Details
    $CheckResults = $html.getElementsByTagName("table")[0].outerHTML

    $HTML2 = New-Object -Com "HTMLFile"

    $HTML2.write([ref]$CheckResults)

    $CheckResults = $HTML2.getElementsByTagName("TR")
    $VMOS = $CheckResults[1].outerHTML.replace("</TH>","").replace("<TR>","").replace("</TR>","").split("<TH>").split("`r`n")[2].replace("<TD>","").replace("</TD>","")
    $VMDatabaseType = $CheckResults[2].outerHTML.replace("</TH>","").replace("<TR>","").replace("</TR>","").split("<TH>").split("`r`n")[2].replace("<TD>","").replace("</TD>","")
    $VMRole = $CheckResults[3].outerHTML.replace("</TH>","").replace("<TR>","").replace("</TR>","").split("<TH>").split("`r`n")[2].replace("<TD>","").replace("</TD>","")
    $VMName = $CheckResults[5].outerHTML.replace("</TH>","").replace("<TR>","").replace("</TR>","").split("<TH>").split("`r`n")[2].replace("<TD>","").replace("</TD>","")
    

    #Get Results
    $CheckResults = $html.getElementsByTagName("table")[2].outerHTML

    $HTML2 = New-Object -Com "HTMLFile"

    $HTML2.write([ref]$CheckResults)

    $CheckResults = $HTML2.getElementsByTagName("TR")

    foreach ($row in $CheckResults)
    {
        $RowHTML = $row.outerhtml

        $rowArr1 = $rowhtml.replace("</TH>","").replace("<TR>","").replace("</TR>","").split("<TH>")

        $rowArray = $RowArr1.split("`r`n")

        $SAPNote = ""
        $MSDoc = ""

        $cellNum = 1
        foreach ($cell in $rowArray)
        {
            if ($cell -match "<TD class=StatusError>") {
                $status = "Error"
                $cell = $cell.replace("<TD class=StatusError>","")
            }
            if ($cell -match "<TD class=StatusWarning>") {
                $status = "Warning"
                $cell = $cell.replace("<TD class=StatusWarning>","")
            }
            if ($cell -match "<TD class=StatusOK>") {
                $status = "Ok"
                $cell = $cell.replace("<TD class=StatusOK>","")
            }
            if ($cell -match "<TD class=StatusInfo>") {
                $status = "Info"
                $cell = $cell.replace("TD class=StatusInfo","")
            }
            $cell = $cell.replace("<TD>","").replace("</TD>","")

            switch ($cellNum) {
                "2" {$CheckID = $cell.trim()}
                "3" {$Description = $cell.trim()}
                "4" {$AdditionalInfo = $cell.trim()}
                "5" {$TestResult = $cell.trim()}
                "6" {$ExpectedResult = $cell.trim()}
                "7" {$Status = $cell.trim()}
                "8" {if ($cell -ne ""){
                        $pass1 = $cell.trim().replace("<A href=""","")
                        $SAPNote = $pass1.substring(0,$pass1.indexof(""" target=_blank>"))}}
                "9" {if($cell -ne "" -and $cell -ne "Testresult"){
                        $pass1 = $cell.trim().replace("<A href=""","")
                        $MSDoc = $pass1.substring(0,$pass1.indexof(""" target"))}}
                default {}
            } 
            $cellNum += 1
        }

        if ($CheckID -ne ""){
            if ($Status -ne "OK") {

                $tmp = New-Object -TypeName psobject
                $tmp | Add-Member -MemberType NoteProperty -Name VMName -Value $VMName
                $tmp | Add-Member -MemberType NoteProperty -Name VMOS -Value $VMOS
                $tmp | Add-Member -MemberType NoteProperty -Name VMDatabase -Value $VMDatabaseType
                $tmp | Add-Member -MemberType NoteProperty -Name VMRole -Value $VMRole
                $tmp | Add-Member -MemberType NoteProperty -Name CheckID -Value $CheckID
                $tmp | Add-Member -MemberType NoteProperty -Name Description -Value $Description
                $tmp | Add-Member -MemberType NoteProperty -Name AdditionalInfo -Value $AdditionalInfo
                $tmp | Add-Member -MemberType NoteProperty -Name TestResult -Value $TestResult
                $tmp | Add-Member -MemberType NoteProperty -Name ExpectedResult -Value $ExpectedResult
                $tmp | Add-Member -MemberType NoteProperty -Name Status -Value $Status
                $tmp | Add-Member -MemberType NoteProperty -Name SAPNote -Value $SAPNote
                $tmp | Add-Member -MemberType NoteProperty -Name MSDoc -Value $MSDoc
                $VMStatus += $tmp
                $IssueFound = $true
            } 
        }

    }

    if (!$IssueFound) {
            $tmp = New-Object -TypeName psobject
            $tmp | Add-Member -MemberType NoteProperty -Name VMName -Value $VMName
            $tmp | Add-Member -MemberType NoteProperty -Name VMOS -Value $VMOS
            $tmp | Add-Member -MemberType NoteProperty -Name VMDatabase -Value $VMDatabaseType
            $tmp | Add-Member -MemberType NoteProperty -Name VMRole -Value $VMRole
            $tmp | Add-Member -MemberType NoteProperty -Name CheckID -Value "No Issues"
            $tmp | Add-Member -MemberType NoteProperty -Name Description -Value "No Issues"
            $tmp | Add-Member -MemberType NoteProperty -Name AdditionalInfo -Value "No Issues"
            $tmp | Add-Member -MemberType NoteProperty -Name TestResult -Value "No Issues"
            $tmp | Add-Member -MemberType NoteProperty -Name ExpectedResult -Value "No Issues"
            $tmp | Add-Member -MemberType NoteProperty -Name Status -Value "No Issues"
            $VMStatus += $tmp
    }
}

if (Test-path -Path "$folderpath\QCOutput.xlsx") {del "$folderpath\QCOutput.xlsx"}
$VmStatus | export-Excel -Path "$folderpath\QCOutput.xlsx"