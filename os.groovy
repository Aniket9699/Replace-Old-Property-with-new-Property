// Get System OS
def osName = System.properties['os.name']
def osVersion = System.properties['os.version']
def osArch = System.properties['os.arch']

println "Operating System: $osName $osVersion ($osArch)"

def filePath = ""

// Get Local IP Address
def localIpAddress = java.net.InetAddress.localHost.hostAddress
println "Local IP Address: $localIpAddress"

// Check if the OS contains "Windows" or "Linux"
if (osName.toLowerCase().contains("windows")) {
    println "This is a Windows operating system."
    filePath="..\\..\\..\\conf\\agent\\installed.properties"
} else if (osName.toLowerCase().contains("linux")) {
    println "This is a Linux operating system."
    filePath="../../../conf/agent/installed.properties"
} else {
    println "This script may not support the current operating system: $osName"
}


def modifiedLines = []
new File(filePath).withReader { reader ->
    reader.eachLine { line ->
        def substringToCheck1 = "agentcomm.server.uri"
        def substringToCheck2 = "agentcomm.proxy.uri"

            if (line.toLowerCase().contains(substringToCheck1.toLowerCase())) {
                // Replace the entire line for "agentcomm.server.uri"
                line = "agentcomm.server.uri=random\\:(wss\\://10.246.64.201\\:7919,wss\\://10.246.64.202\\:7919,wss\\://10.177.48.201\\:7919,wss\\://10.177.48.202\\:7919)"
                println "String contains '$substringToCheck1' (case-insensitive). Replacing line with: $line"
            } else if (line.toLowerCase().contains(substringToCheck2.toLowerCase())) {
                // Replace the entire line for "agent.brokerUrl"
                line = "agentcomm.proxy.uri=random\\:(http\\://10.246.64.207\\:20080,http\\://10.246.64.208\\:20080,http\\://10.177.48.207\\:20080,http\\://10.177.48.208\\:20080)"
                println "String contains '$substringToCheck2' (case-insensitive). Replacing line with: $line"
            }

            modifiedLines.add(line)
        }
    }
new File(filePath).text = modifiedLines.join(System.getProperty('line.separator'))
