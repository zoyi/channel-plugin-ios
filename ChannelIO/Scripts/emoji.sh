echo "Downloading Emoji data"
curl -g https://cdn.channel.io/emoji/v3/emojis.min.json >> emojis.min.json
echo "Copying to destination ${SRCROOT}"
cp -R emojis.min.json ${SRCROOT}/ChannelIO/Assets/emojis.json
echo "Emoji has been donwloaded."
rm emojis.min.json
