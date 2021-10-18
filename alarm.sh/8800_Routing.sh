#!/bin/bash

WHO=$1; DID=$2; CID=$3;
ChID="yourgroupid"
#URL="https://api.telegram.org/bot$token"; token="452852860:AAHOIugk_Jr8f_9EDNm6jmo3ebQOT4J8v1Y"
#mtd_send1=$URL/sendMessage
TXT="#WARNING 🔥 $WHO 🔥 CallerID: $CID 🔥 Exten: $DID"
#"Клиент: $WHO. Попытка международного вызова на номер $DID с номера $CID"
JSONT='{ "chat_id" : "'$ChID'" , "text" : "'$TXT'" }'

    send_text()
    {
    #sendMessage
    /usr/bin/curl --header 'Content-Type: application/json' --request 'POST' --data "$JSONT" https://api.telegram.org/bot"youbotid"/sendMessage
    }


send_text
