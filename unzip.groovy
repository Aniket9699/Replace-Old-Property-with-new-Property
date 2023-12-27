// File: UnzipScript.groovy

import java.nio.file.Path
import java.nio.file.Paths
import java.util.zip.ZipFile
import java.util.zip.ZipEntry
import java.nio.file.Files

// Function to unzip a file into a destination directory
def unzipFile(filename, destinationPath) {
    // Ensure the destination directory exists
    def destPath = Paths.get(destinationPath)
    Files.createDirectories(destPath)

    // Use Java's java.util.zip package to unzip the file
    def zipFile = new ZipFile(filename)
    zipFile.entries().each { entry ->
        def entryName = entry.name
        def entryPath = destPath.resolve(entryName)

        if (entry.isDirectory()) {
            // Create directories if the entry is a directory
            Files.createDirectories(entryPath)
        } else {
            // Create parent directories if they don't exist
            Files.createDirectories(entryPath.parent)

            // Extract the file
            Files.copy(zipFile.getInputStream(entry), entryPath)
        }
    }

    zipFile.close()
}

// Check if the correct number of command line arguments is provided
if (args.length != 2) {
    println "Usage: groovy UnzipScript.groovy <filename> <destinationPath>"
    System.exit(1)
}

// Retrieve command line arguments
def sourceZip = args[0]
def destinationDir = args[1]

// Call the unzipFile function with command line arguments
unzipFile(sourceZip, destinationDir)

println "Unzipped $sourceZip to $destinationDir"
