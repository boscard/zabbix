#!/bin/bash

apacheConfDir="/etc/httpd"

function discovery() {
        certFiles=`grep -R -v "^#" $apacheConfDir/* | grep SSLCertificateFile | sed 's/.*SSLCertificateFile//' | sort | uniq`
        echo '{'
        echo '  "data":['
        echo
        counter=0
        for certFile in $certFiles
        do
                if [ $counter -ne 0 ]
                then
                        echo ,
                fi
                counter=$((counter+1))
                echo -n "  { \"{#CERTFILE}\":\"$certFile\", \"{#CERTCN}\":\"`openssl x509 -in $certFile -noout -subject | grep CN | sed -e 's:.*CN=::'`\"}"
        done
        echo -e "\n"
        echo '  ]'
        echo '}'
}

function expirationDate() {
        openssl x509 -in $1  -noout -enddate | sed 's/notAfter=//'
}

function expirationTime() {
        expDate=`expirationDate $1`
        date --date="$expDate" "+%s"
}

case $1 in
        discovery)
                discovery;;
        expirationDate)
                expirationDate $2;;
        expirationTime)
                expirationTime $2;;
esac
