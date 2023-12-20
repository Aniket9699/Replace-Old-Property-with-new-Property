// Get System OS
def osName = System.properties['os.name']
def osVersion = System.properties['os.version']
def osArch = System.properties['os.arch']

println "Operating System: $osName $osVersion ($osArch)"


// Get Local IP Address
def localIpAddress = java.net.InetAddress.localHost.hostAddress
println "Local IP Address: $localIpAddress"

def filepath=""
if (osName.toLowerCase().contains("windows")) {
    println "This is Windows System."
    filepath="..\\..\\..\\conf\\agent\\installed.properties"
    println "$filepath"
    readFileContent(filepath)
} else if (osName.toLowerCase().contains("linux")) {
    println "This is Linux System."
    filepath="../../../con/agent/installed.properties"
    println "$filepath"
}

def readFileContent(String filePath) {
    if (new File(filePath).exists()) {
        println "-----------------------------------------------------------"
        println "File is present"
        println "-----------------------------------------------------------"
    } else {
        println "-----------------------------------------------------------"
        println "Error:- File is not present"
        System.exit(1)
        println "-----------------------------------------------------------"
    }
    def modifiedLines = []
    new File(filePath).withReader { reader ->
    reader.eachLine { line ->
        def oldJavaHome="ibm-java-win-x86_64-71"
            if (line.toLowerCase().contains(oldJavaHome.toLowerCase())) {
                line = "IBM\\ UrbanCode\\ Deploy/java.home=C\\:\\\\Program Files\\\\ibm-java-win-x86_64-80\\\\jre"
                println "String contains '$oldJavaHome' (case-insensitive). Replacing line with: $line"
            } else if (line.toLowerCase().contains("java.home".toLowerCase())) {
                println "Agent Java:- $line"
            }
            modifiedLines.add(line)
        }
    }
    new File(filePath).text = modifiedLines.join(System.getProperty('line.separator'))
}
