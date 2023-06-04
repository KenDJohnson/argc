def _argc_complete_path [name: string, is_dir: bool] {
    let sep = if $nu.os-info.family == "windows" {
        "\\"
    } else {
        "/"
    }
    let paths = (ls ($name + '*') | skip 2)
    let paths = if $is_dir {
        $paths | where type == dir
    } else {
        $paths
    }
    $paths | each {|it| 
        if $it.type == 'dir' {
            $it.name + $sep 
        } else {
            $it.name 
        }
    }
}

def _argc_complete_list [] {
    each { |line| $line | split column "\t" value description } | flatten 
}

def _argc_completer [words: list<string>] {
    let word1 = $words.0
    let scriptfile = (try { 
        if $word1 == 'argc' {
            do { argc --argc-script-path } | complete | get stdout 
        } else {
            which $word1 | get 0.path
        }
    })
    if not ($scriptfile | path exists) {
        return (_argc_complete_path ($words | last) false | _argc_complete_list)
    }
    mut line = ($words | skip 1 | str join " ")
    if $line == "" {
        $line = " "
    }
    mut candicates = ((argc --argc-compgen fish $scriptfile $line) | str trim | split row "\n")
    if ($candicates | length) == 1  {
        if $candicates.0 == '__argc_comp:file' {
            $candicates = (_argc_complete_path ($words | last) false)
        } else if $candicates.0 == '__argc_comp:dir' {
            $candicates = (_argc_complete_path ($words | last) true)
        }
    }
    $candicates | _argc_complete_list
}