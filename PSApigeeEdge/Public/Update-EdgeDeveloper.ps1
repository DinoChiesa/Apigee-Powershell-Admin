Function Update-EdgeDeveloper {
    <#
    .SYNOPSIS
        Update a developer in Apigee Edge.

    .DESCRIPTION
        Update a Developer in Apigee Edge. When invoking this cmdlet you need
        to specify the firstname, last name, email, and username, at a minimum.  You
        may also specify attributes. 

    .PARAMETER Name
        The name to give to this new Developer. It must be unique in the organization.

    .PARAMETER Email
        The Email address of the developer to create.

    .PARAMETER First
        The first (given) name of the developer to create.
        
    .PARAMETER Last
        The last (sur-) name of the developer to create.

    .PARAMETER Attributes
        Optional. Hashtable specifying custom attributes for the developer.

    .PARAMETER Org
        The Apigee Edge organization. The default is to use the value from Set-EdgeConnection.

    .EXAMPLE
        Update-EdgeDeveloper -Name 'DC' -First Dino -Last Chiesa -Email dchiesa@example.org -Attributes @{ 'shoesize' = 9 }

    .FUNCTIONALITY
        ApigeeEdge

    #>

    [cmdletbinding()]
    PARAM(
        [Parameter(Mandatory=$True)][string]$Name,
        [Parameter(Mandatory=$True)][string]$Email,
        [Parameter(Mandatory=$True)][string]$First,
        [Parameter(Mandatory=$True)][string]$Last,
        [hashtable]$Attributes,
        [string]$Org
    )
    
    $Options = @{ Collection = 'developers' }
    
    if ($PSBoundParameters['Debug']) {
        $Options.Add( 'Debug', $Debug )
    }
    if ($PSBoundParameters['Org']) {
        $Options.Add( 'Org', $Org )
    }

    if (!$PSBoundParameters['Email']) {
      throw [System.ArgumentNullException] "You must specify the -Email option."
    }
    if (!$PSBoundParameters['First']) {
      throw [System.ArgumentNullException] "You must specify the -First option."
    }
    if (!$PSBoundParameters['Last']) {
      throw [System.ArgumentNullException] "You must specify the -Last option."
    }
    if (!$PSBoundParameters['Name']) {
      throw [System.ArgumentNullException] "You must specify the -Name option."
    }

    $Options.Add( 'Name', $Name )

    $Payload = @{
      email = $Email
      userName = $Name
      firstName = $First
      lastName = $Last
    }

    if ($PSBoundParameters['Attributes']) {
      $a = @(ConvertFrom-HashtableToAttrList -Values $Attributes)
      $Payload.Add('attributes', $a )
    }
    $Options.Add( 'Payload', $Payload )

    Send-EdgeRequest @Options
}
