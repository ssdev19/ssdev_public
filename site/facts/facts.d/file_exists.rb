# Fact to identify if a file is present on disk.
Facter.add('file_exists') do

    # Check file system for C:\file.txt and return value of true or false
      setcode do
        result = Facter::Core::Execution.exec('powershell.exe if (Get-Item C:\file.txt -ErrorAction SilentlyContinue) {Write-Output true} else {Write-Output False}')
    
    # Take string result returned by Powershell and convert to boolean for fact value
        if result == "true"
          true
        else
          false
        end
      end
    end