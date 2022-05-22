# This function runs an installer, waiting until it stops execution.
function Invoke-Installer($path) {
    $process = Start-Process -Wait -WorkingDirectory (Split-Path -Path $path -Parent) -FilePath "$pwd\$path"
}

# This function runs a file, and doesn't wait for termination.
function Invoke-File($path) {
    Start-Process -Verb "Open" -FilePath "$pwd\$path" 
}

# This function runs a batch file, and waits for termination.
function Invoke-BatchFile($path) {
    # The argument list looks weird but that's so the concatenation of the quotes around the parameter works properly.
    $process = Start-Process -Wait -FilePath "cmd" -WorkingDirectory (Split-Path -Path $path -Parent) -ArgumentList (("/c ")+('"')+("$pwd\$path")+('"'))
}

# This function adds a .reg file's entries to the registry.
function Invoke-RegFile($path) {
    # The argument list looks weird but that's so the concatenation of the quotes around the parameter works properly.
    $process = Start-Process -Wait -FilePath "cmd" -WorkingDirectory (Split-Path -Path $path -Parent) -ArgumentList (("/c reg import ")+('"')+("$pwd\$path")+('"'))
}

# This function copies a bunch of files using XCOPY.
function Copy-Files($pathto, $pathfrom) {
    $process = Start-Process -Wait -FilePath "cmd" -WorkingDirectory $pathto -ArgumentList (("/c xcopy /e /h /y /b /j ")+('"')+("$pwd\$pathfrom")+('" "')+($pathto)+('"'))
}

# This reads all command lines and processes them.
Get-Content ".\Commands.txt" | ForEach-Object {
    #We need to split the command from the parameter(s)
    $commandline = $_.ToString().Split("=")
    Switch ($commandline[0])
    {
        "Install" {
            # Install an single executable.
            Invoke-Installer -path $commandline[1]
        }

        "Open" {
            # Open a file.
            Invoke-File -path $commandline[1]
        }

        "InstallAll" {
            # Install multiple executables.
            Get-ChildItem -Path $commandline[1] | ForEach-Object {
                Invoke-Installer (($commandline[1])+"\"+($_.Name))
            }
        }

        "InstallBatch" {
            # Run a batch file.
            Invoke-BatchFile -path $commandline[1]
        }

        "ImportRegFile" {
            # Import a reg file using the reg add command
            Invoke-RegFile -path $commandline[1]
        }

        "CopyContents" {
            # Copy Files to the appropriate destination.
            Copy-Files -pathfrom $commandline[1] -pathto ([System.Environment]::ExpandEnvironmentVariables($commandline[2]))
        }
    }
}