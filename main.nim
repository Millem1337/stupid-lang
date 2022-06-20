import std/strutils
import tables

proc clearLog() =
    var fileC:File = open(".logs", fmWrite)
    fileC.write("")

proc log(text: string) =
    var file:File = open(".logs", fmAppend)
    file.write(text & "\n")
    file.close()

proc getSettings(): string =
    log "//// Getting settings..."
    var file: File
    var fileToInterp: string

    var fileC:File = open(".logs", fmWrite)

    if file.open(".settings") == true:
        log "//// Getting settings file"
        fileToInterp = file.readLine().split(':')[1]
    else:
        log "++++ Creating settings file"
        fileC.write("filename:main.stupid")
        fileToInterp = "main.stupid"
    return fileToInterp

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

proc interpret(code: string): seq = 
    let lines = code.split(';')
    var variables = {"def": "def"}.toTable()
    var ifLines = @[-1]

    for i, line in lines:
        if ifLines.contains(i):
            continue
        if line.contains("clog"):
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
        if line.contains("cin"):
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
        if line.contains("var"):
            if line.split(' ').len < 1:
                log "---- Syntax error in line " & $(i+1) & "\n---- The variable should be declared like this (example): var a = \"a\";"
                return
            if line.contains('='):
                let spaces = line.split(' ')[1 .. line.split(' ').len-1]
                var str: string
                var stopfor: bool = false
                for i,space in spaces:
                    if stopfor == true:
                        continue
                    if space.contains('\"'):
                        for s in spaces[i .. spaces.len-1]:
                            str = str & s & " "
                        stopfor = true
                        continue
                    str = str & space.replace(" ", "")
                let namevar = str.split('=')[0]
                let variable = str.split('=')[1]
                variables.add namevar, variable
            else:
                let namevar = line.split(' ')[1]
                variables.add namevar, "None"
                continue
        if line.contains("//"):
            continue
        if line.contains("remVar"):
            if line.split("(")[1].len < 2:
                log "---- Syntax error in line " & $(i+1)
                return
            else:
                if variables.contains(line.split("(")[1][0 .. line.split("(")[1].len-2]):
                    variables.del(line.split("(")[1][0 .. line.split("(")[1].len-2])
                else:
                    log "---- Variable not found in line " & $(i+1)
                    return
        if line.contains("if"):
            if line.contains("=="):
                var fvar = line.split('(')[1].split("==")[0].replace(" ", "")
                var svar = line.split(')')[0].split("==")[1].replace(" ", "")
                var stopIf = false
                var codeIf: string

                if not fvar.contains("\""):
                    if not variables.contains(fvar):
                        log "---- Variable not found in line " & $(i+1)
                        return
                    fvar = variables[fvar].replace(" ", "")
                if not svar.contains("\""):
                    if not variables.contains(svar):
                        log "---- Variable not found in line " & $(i+1)
                        return
                    svar = variables[svar].replace(" ", "")

                if svar != fvar:
                    for nt,l in lines[i+1 .. lines.len-1]:
                        if stopIf == true:
                            continue
                        if l.contains("end"):
                            stopIf = true
                            continue
                        else:
                            ifLines.add(nt + i + 1)
                            codeIf = codeIf & l & ";"
            if line.contains("!="):
                var fvar = line.split('(')[1].split("!=")[0].replace(" ", "")
                var svar = line.split(')')[0].split("!=")[1].replace(" ", "")
                var stopIf = false
                var codeIf: string

                if not fvar.contains("\""):
                    if not variables.contains(fvar):
                        log "---- Variable not found in line " & $(i+1)
                        return
                    fvar = variables[fvar].replace(" ", "")
                if not svar.contains("\""):
                    if not variables.contains(svar):
                        log "---- Variable not found in line " & $(i+1)
                        return
                    svar = variables[svar]

                if svar == fvar:
                    for nt,l in lines[i+1 .. lines.len-1]:
                        if stopIf == true:
                            continue
                        if l.contains("end"):
                            stopIf = true
                            continue
                        else:
                            ifLines.add(nt + i + 1)
                            codeIf = codeIf & l & ";"
    log "++++ Interpreted"

clearLog()
interpret(getFile(getSettings()))