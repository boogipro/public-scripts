function New-netapp_share {
    <#
    .SYNOPSIS
        Creates Share due to already existing NTFS Structure (Data and ACL)
    .DESCRIPTION
        Create Share only without backend structure, Folder and ACL need to be existing already.
    .PARAMETER svmname
        SVM Hostname
    .PARAMETER sharename
        Cifs Sharename
    .PARAMETER nacontroller
        Controller name
    .PARAMETER closeconnection
        If set, Controller connection will be closed
    .PARAMETER svmvolumename
        Name of the target Volume
    .EXAMPLE
        New-netapp_share -svmname 'SVM_DST' -sharename 'Finance' -nacontroller 'ControllerIP' -closeconnection
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]
        $svmname,

        [Parameter(Mandatory = $true)]
        [string]
        $sharename,

        [Parameter(Mandatory = $false)]
        [string]
        $nacontroller = "",

        [Parameter(Mandatory = $false)]
        [switch]
        $closeconnection,

        [Parameter(Mandatory = $true)]
        [string]
        $svmvolumename
    )

    try {
        # check if na connection already exists or requiered
        if ($nacontroller -ne "") {
            write-verbose  "No existing NA-Connection, trying to connect: $($nacontroller)"
            Connect-NcController -Name $nacontroller -Credential (Get-Credential -Message 'Enter Controller Admin User')
            write-verbose "Connection established to $($nacontroller)"
        }

        # fetch volume 
        $fetchedvol = get-ncvol $svmvolumename -VserverContext $svmname      
        write-verbose "Fetched Volume: $($fetchedvol)"

        # create share
        $sharepath = "/$(($fetchedvol.JunctionPath.split("/"))[1])/$($sharename)"
        Add-NcCifsShare -Name $sharename -Path $sharepath -VserverContext $svmname -Erroraction Stop | Out-Null
        Start-Sleep -Seconds 2
        write-verbose "Share created, path: $($sharepath)"

        # set share options
        Set-NcCifsShare -Name $sharename -AccessBasedEnumeration $true -ChangeNotify $true -Oplocks $true -OfflineFilesMode 'none' -VserverContext $svmname | Out-Null
        write-verbose "Share Option setup done"

        # set share permission
        Add-NcCifsShareAcl -Share $sharename -UserOrGroup 'NT AUTHORITY\Authenticated Users' -Permission change -UserGroupType 'windows' -VserverContext $svmname | Out-Null
        Remove-NcCifsShareAcl -Share $sharename -UserOrGroup 'Everyone' -UserGroupType 'windows' -VserverContext $svmname | Out-Null
        write-verbose "Share permission setup done"

        # close connection if defined
        if($closeconnection){
            $global:CurrentNcController = $null
            write-verbose "Connection closed"
        }
    }
    catch {
        throw
    }
}