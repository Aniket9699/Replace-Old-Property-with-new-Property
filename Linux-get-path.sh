systemIpaddress="192.168.29.220"
agentdata=$(cat Ip-Details | grep $systemIpaddress)
agentpath=$(echo "$agentdata" | cut -d '=' -f2)

if [[ -d "${agentpath}/bin" ]]; then
	echo "Path is present"
	ls -lrt
	cd ${agentpath}/bin
	./groovy /d/Agent-Upgrade/ucd-agent-7.0.3/agent/os.groovy
else
	echo "Unable to find ${agentpath}/bin"
fi
