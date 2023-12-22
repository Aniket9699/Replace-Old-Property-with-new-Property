import java.util.regex.Pattern
import java.util.regex.Matcher

if (args.length < 3) {
    println "Usage: groovy PathScript.groovy <file path> <old java path> <new java path>"
    System.exit(1)
}

def filePath = args[0]
def oldJava = args[1]
def newJava = args[2]

try {
    if (new File(filePath).exists()) {
        println "File is present at $filePath"
        println "-----------------------------------System Information-----------------------------------"
        
        def osName = System.properties['os.name']
        def osVersion = System.properties['os.version']
        def osArch = System.properties['os.arch']
        def localIpAddress = java.net.InetAddress.localHost.hostAddress
        
        println "Operating System: $osName $osVersion ($osArch)"
        println "Local IP Address: $localIpAddress"
        println "----------------------------------------------------------------------------------------"
        
        def fileContent = new File(filePath).text

        // Check if oldJava is present in the file
        if (fileContent.contains(oldJava)) {
            def pattern = Pattern.quote(oldJava)
            def replacement = Matcher.quoteReplacement(newJava)
            println "Replacing $oldJava with $newJava"

            def modifiedContent = fileContent.replaceAll(pattern, replacement)

            new File(filePath).text = modifiedContent

            println("File updated successfully.")
        } else {
            println "The file does not contain the specified old Java path .i.e. $oldJava"
        }
    } else {
        println "Error: File is not at $filePath"
    }
} catch (Exception e) {
    println "Error: ${e.message}"
    e.printStackTrace()
    System.exit(1)
} finally {
    println "----------------------------------------------------------------------------------------"
}
