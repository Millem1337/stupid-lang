import std/strutils
import tables

proc clearLog() =
    var fileC:File = open(".logs", fmWrite)
    fileC.write("")

proc log(text: string) =
    var file:File = open(".logs", fmAppend)
    file.write(text & "\n")
    file.close()

proc getFile(fileName: string): string =
    log "//// Getting file " & fileName & "..."
    var file: File

    if file.open(fileName) == true:
        log "++++ File can be interpreted"
    else:
        log "---- File cannot be interpreted"
        return
    log "//// Splitting lines"
    var text: string
    for line in file.lines:
        text = text & line
    return text

proc compile(code: string): seq = 
    let lines = code.split(';')
    var variables = {"def": "def"}.toTable()
    for i, line in lines:
        if line.startsWith("clog"):
            if line.contains("\""):
                echo line.split('\"')[1]
            else:
                if line.split("(")[1].len < 2:
                    echo ""
                else:
                    if variables.contains(line.split("(")[1][0 .. line.split("(")[1].len-2]):
                        if variables[line.split("(")[1][0 .. line.split("(")[1].len-2]].contains("\""):
                            echo variables[line.split("(")[1][0 .. line.split("(")[1].len-2]].split('\"')[1]
                        else:
                            echo variables[line.split("(")[1][0 .. line.split("(")[1].len-2]]
                    else:
                        log "---- Variable not found in line " & $(i+1)
                        return
        if line.startsWith("cin"):
            var cin: string
            cin = readLine(stdin)
            if line.split("(")[1].len < 2:
                continue
            else:
                if variables.contains(line.split("(")[1][0 .. line.split("(")[1].len-2]):
                    variables[line.split("(")[1][0 .. line.split("(")[1].len-2]] = "\"" & cin & "\""
                else:
                    log "---- Variable not found in line " & $(i+1)
                    return
        if line.startsWith("var"):
            if line.split(' ').len < 4:
                log "---- Syntax error in line " & $(i+1) & "\n---- The variable should be declared like this (example): var a = \"a\";"
                return
            let namevar = line.split(' ')[1]
            let variable = line.split(' ')[3]
            variables.add namevar, variable
        if line.startsWith("//"):
            continue
        if line.startsWith("remVar"):
            if line.split("(")[1].len < 2:
                log "---- Syntax error in line " & $(i+1)
                return
            else:
                if variables.contains(line.split("(")[1][0 .. line.split("(")[1].len-2]):
                    variables.del(line.split("(")[1][0 .. line.split("(")[1].len-2])
                else:
                    log "---- Variable not found in line " & $(i+1)
                    return
    log "++++ Compiled"

clearLog()
compile(getFile("test.stupid"))