#
# Module manifest for module 'XboxStreamingFix'
#
# Generated by: Casey MacPherson
#
# Generated on: 10/7/2018
#

@{

# Script module or binary module file associated with this manifest.
RootModule = '.\XboxStreamingFix.psm1'

# Version number of this module.
ModuleVersion = '0.1'

# Supported PSEditions
CompatiblePSEditions = @('Desktop')

# ID used to uniquely identify this module
GUID = '9ab785c0-c50f-4c45-b7e0-5f16ac3804f7'

# Author of this module
Author = 'Casey MacPherson'

# Company or vendor of this module
CompanyName = 'N/A'

# Copyright statement for this module
Copyright = '(c) 2018 Casey MacPherson. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Provides functions for simplifying fixing Xbox streaming issue with Hyper-V and Docker'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

FunctionsToExport = @('Initialize-XboxStreamingFix','Undo-XboxStreamingFix')

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

PrivateData = @{

    PSData = @{
        Tags = @('Xbox','Docker','Xbox One','Hyper-V','Streaming')
        ProjectUri = 'https://github.com/CaseyMacPherson/XboxStreamingFix'
    }
}
}

