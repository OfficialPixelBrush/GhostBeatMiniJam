if [ -f "deployip.txt" ]; then
    SERVER=$(<deployip.txt)
    REMOTE_PATH="/root/files/${PWD##*/}/"
    LOCAL_PATH="build/"

    ssh root@"$SERVER" "mkdir -p '$REMOTE_PATH'"
    scp -r "$LOCAL_PATH"/* root@"$SERVER":"$REMOTE_PATH"
else
    echo "deployip.txt not found!"
fi