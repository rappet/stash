
use builtin;
use str;

set edit:completion:arg-completer[rust-rest-server-template] = {|@words|
    fn spaces {|n|
        builtin:repeat $n ' ' | str:join ''
    }
    fn cand {|text desc|
        edit:complex-candidate $text &display=$text' '(spaces (- 14 (wcswidth $text)))$desc
    }
    var command = 'rust-rest-server-template'
    for word $words[1..-1] {
        if (str:has-prefix $word '-') {
            break
        }
        set command = $command';'$word
    }
    var completions = [
        &'rust-rest-server-template'= {
            cand -p 'Port of the HTTP server'
            cand --http-port 'Port of the HTTP server'
            cand -a 'Address to listen on (`0.0.0.0`/`::` or `127.0.0.1`/`::1`)'
            cand --http-address 'Address to listen on (`0.0.0.0`/`::` or `127.0.0.1`/`::1`)'
            cand -h 'Print help'
            cand --help 'Print help'
            cand -V 'Print version'
            cand --version 'Print version'
        }
    ]
    $completions[$command]
}
