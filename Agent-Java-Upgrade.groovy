// Get System OS
def osName = System.properties['os.name']
def osVersion = System.properties['os.version']
def osArch = System.properties['os.arch']

println "Operating System: $osName $osVersion ($osArch)"


// Get Local IP Address
def localIpAddress = java.net.InetAddress.localHost.hostAddress
println "Local IP Address: $localIpAddress"

def filepath=""
def configurefilepath=""
def fileagentpath=""

if (osName.toLowerCase().contains("windows")) {
    println "This is Windows System."
    filepath="..\\..\\..\\conf\\agent\\installed.properties"
    configurefilepath="..\\..\\..\\bin\\configure-agent.cmd"

    // update installed.properties and configure-agent.cmd
    readFileContent(filepath,"ibm-java-win-x86_64-71","IBM\\ UrbanCode\\ Deploy/java.home=C\\:\\\\Program Files\\\\ibm-java-win-x86_64-80\\\\jre")
    readFileContent(configurefilepath,"ibm-java-win-x86_64-71","set JAVA_HOME=C:\\Program Files\\ibm-java-win-x86_64-80\\jre")
} else if (osName.toLowerCase().contains("linux")) {
    println "This is Linux System."
    filepath="../../../conf/agent/installed.properties"
    fileagentpath="../../../bin/agent"
    configurefilepath="../../../bin/configure-agent"
    
    // update installed.properties and bin/configure-agent and bin/agent
    readFileContent(filepath,"ibm-java-win-x86_64-71","IBM\\ UrbanCode\\ Deploy/java.home=/opt/ibm-ucd/agent/opt/Agent_Java/jre")
    readFileContent(configurefilepath,"ibm-java-win-x86_64-71","set JAVA_HOME=/opt/ibm-ucd/agent/opt/Agent_Java/jre")
    readFileContent(fileagentpath,"ibm-java-win-x86_64-71","JAVA_HOME=\"/opt/ibm-ucd/agent/opt/Agent_Java/jre\"")

}

def readFileContent(String filePath,String oldJavaHome,String newJavaPath) {
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
            if (line.toLowerCase().contains(oldJavaHome.toLowerCase())) {
                line = "$newJavaPath"
                println "String contains '$oldJavaHome' (case-insensitive). Replacing line with: $line"
            } else if (line.toLowerCase().contains("java.home".toLowerCase())) {
                println "Agent Java:- $line"
            }  else if (line.toLowerCase().contains("set JAVA_HOME".toLowerCase())) {
                println "Agent Java:- $line"
            }
            modifiedLines.add(line)
        }
    }
    new File(filePath).text = modifiedLines.join(System.getProperty('line.separator'))
}
