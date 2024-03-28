@{
    IncludeRules = @(
        'PSAlignAssignmentStatement',
        'PSAvoidAssignmentToAutomaticVariable',
        'PSAvoidDefaultValueForMandatoryParameter',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidExclaimOperator',
        'PSAvoidGlobalAliases',
        'PSAvoidGlobalFunctions',
        'PSAvoidGlobalVars',
        'PSAvoidInvokingEmptyMembers',
        'PSAvoidLongLines',
        'PSAvoidMultipleTypeAttributes',
        'PSAvoidNullOrEmptyHelpMessageAttribute',
        'PSAvoidOverwritingBuiltInCmdlets',
        'PSAvoidSemicolonsAsLineTerminators',
        'PSAvoidShouldContinueWithoutForce',
        'PSAvoidTrailingWhitespace',
        'PSAvoidUsingAllowUnencryptedAuthentication',
        'PSAvoidUsingBrokenHashAlgorithms',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSAvoidUsingDoubleQuotesForConstantString',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingUsernameAndPasswordParams',
        'PSAvoidUsingWMICmdlet',
        'PSAvoidUsingWriteHost',
        'PSMisleadingBacktick',
        'PSMissingModuleManifestField',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSPossibleIncorrectComparisonWithNull',
        'PSPossibleIncorrectUsageOfAssignmentOperator',
        'PSPossibleIncorrectUsageOfRedirectionOperator',
        'PSProvideCommentHelp',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSReviewUnusedParameter',
        'PSShouldProcess',
        'PSUseApprovedVerbs',
        'PSUseBOMForUnicodeEncodedFile',
        'PSUseCmdletCorrectly',
        'PSUseCompatibleCmdlets',
        'PSUseCompatibleCommands',
        'PSUseCompatibleSyntax',
        'PSUseCompatibleTypes',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseCorrectCasing',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseLiteralInitializerForHashtable',
        'PSUseOutputTypeCorrectly',
        'PSUseProcessBlockForPipelineCommand',
        'PSUsePSCredentialType',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSUseSupportsShouldProcess',
        'PSUseToExportFieldsInManifest',
        'PSUseUsingScopeModifierInNewRunspaces',
        'PSUseUTF8EncodingForHelpFile'
    )

    Rules = @{
        PSAlignAssignmentStatement = @{
            Enable = $true
            CheckHashtable = $true
        }
        PSAvoidExclaimOperator = @{
            Enable = $true
        }
        PSAvoidLongLines = @{
            Enable = $true
            MaximumLineLength = 180
        }
        PSAvoidOverwritingBuiltInCmdlets = @{
            PowerShellVersion = @('core-6.1.0-windows')
        }
        PSAvoidSemicolonsAsLineTerminators = @{
            Enable = $true
        }
        PSAvoidUsingDoubleQuotesForConstantString = @{
            Enable = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NoEmptyLineBefore = $true
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $true
            BlockComment = $true
            VSCodeSnippetCorrection = $false
            Placement = 'before'
        }
        PSReviewUnusedParameter = @{
            CommandsToTraverse = @(
                'Assert-Parameter'
            )
        }
        PSUseCompatibleCmdlets = @{
            compatibility = @('core-6.1.0-windows')
        }
        PSUseCompatibleCommands = @{
            Enable = $true
            TargetProfiles = @(
                'win-8_x64_10.0.17763.0_7.0.0_x64_3.1.2_core'
                'win-4_x64_10.0.18362.0_7.0.0_x64_3.1.2_core'
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core'
            )
            IgnoreCommands = @(
            )
        }
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @('7.4', '7.2', '6.0')
        }
        PSUseCompatibleTypes = @{
            Enable = $true
            TargetProfiles = @(
                'win-8_x64_10.0.17763.0_7.0.0_x64_3.1.2_core'
                'win-4_x64_10.0.18362.0_7.0.0_x64_3.1.2_core'
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core'
            )
            IgnoreTypes = @(
            )
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'tab'
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $true
            CheckParameter = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }
        PSUseCorrectCasing = @{
            Enable = $true
        }
        PSUseSingularNouns = @{
            Enable = $true
            NounAllowList = @('Data', 'Windows', 'Elements', 'Fields')
        }
    }
}
