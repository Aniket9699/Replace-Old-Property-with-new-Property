timestamp=$(date +"%Y%m%d%H%M%S")
File="installed.properties"
TempFile=$(mktemp)

while IFS= read -r line; do
    if echo "$line" | grep -q "agentcomm.server.uri"; then
        echo "String contains 'agentcomm.server.uri'"
        echo "New line: agentcomm.server.uri=random\:(wss\://localhost\:7919,wss\://192.168.30.43\:7919)"
        # Replace the old line with the new line
        echo "agentcomm.server.uri=random\:(wss\://localhost\:7919,wss\://192.168.30.43\:7919)" >> "$TempFile"
    else
        echo "$line" >> "$TempFile"
    fi
done < "$File"

# Replace the original file with the modified content
mv "$TempFile" "$File"

echo "File modification complete."
