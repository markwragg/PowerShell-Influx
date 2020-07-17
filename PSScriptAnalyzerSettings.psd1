@{
    ExcludeRules = @(
        'PSAvoidTrailingWhitespace',
        'PSAvoidGlobalVars',
        'PSAvoidUsingCmdletAliases',
        'PSUseDeclaredVarsMoreThanAssignments'
    )

    Severity = @(
        "Warning",
        "Error"
    )

    Rules = @{}
}
