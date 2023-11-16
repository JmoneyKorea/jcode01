function Compare-FileSize {
    param (
        [Parameter(Mandatory=$true)]
        [string]$file1,
        [Parameter(Mandatory=$true)]
        [string]$file2
    )

    # Check if the files exist
    if (-not (Test-Path $file1)) {
        Write-Output "File '$file1' does not exist."
        return
    }

    if (-not (Test-Path $file2)) {
        Write-Output "File '$file2' does not exist."
        return
    }

    # Measure the time it takes to run the script
    $timeTaken = Measure-Command {

        # Get the file details
        $file1Details = Get-Item $file1
        $file2Details = Get-Item $file2

        # Get the file sizes
        $file1Size = $file1Details.Length
        $file2Size = $file2Details.Length

        # Compare the file sizes
        if ($file1Size -eq $file2Size) {
            Write-Output "The files are the same size."
        } else {
            Write-Output "The files are not the same size."
        }
    }

    # Output the time taken
    Write-Output "Time taken: $($timeTaken.TotalMilliseconds) ms"
}