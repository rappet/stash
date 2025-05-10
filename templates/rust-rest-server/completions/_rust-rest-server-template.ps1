
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'rust-rest-server-template' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'rust-rest-server-template'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'rust-rest-server-template' {
            [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Port of the HTTP server')
            [CompletionResult]::new('--http-port', '--http-port', [CompletionResultType]::ParameterName, 'Port of the HTTP server')
            [CompletionResult]::new('-a', '-a', [CompletionResultType]::ParameterName, 'Address to listen on (`0.0.0.0`/`::` or `127.0.0.1`/`::1`)')
            [CompletionResult]::new('--http-address', '--http-address', [CompletionResultType]::ParameterName, 'Address to listen on (`0.0.0.0`/`::` or `127.0.0.1`/`::1`)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Path to the SQLite database file')
            [CompletionResult]::new('--database-file', '--database-file', [CompletionResultType]::ParameterName, 'Path to the SQLite database file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
