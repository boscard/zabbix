#!/bin/bash
# Scrit used by zabbix to VM's disk monitoring

# Return zabbix discovery JSON
disksList() {

directories="/var/lib/libvirt/images"
fileExtensions="qcow2 qcow img iso"

disksImages=""

for directory in $directories
do
        for fileExtension in $fileExtensions                                                                                                                                                       
        do                                                                                                                                                                                      
                disksImages="`find $directory -iname "*.$fileExtension"` $disksImages"                                                                                                           
        done                                                                                                                                                                                    
done                                                                                                                                                                                            
                                                                                                                                                                                                
echo -e "{\n"                                                                                                                                                                                   
echo -e "\t\"data\":[\n"                                                                                                                                                                        
first=1                                                                                                                                                                                      
for diskImage in $disksImages                                                                                                                                                                 
do                                                                                                                                                                                              
        fileExtension=`/usr/bin/qemu-img info $diskImage | grep "file format:" | sed 's/file format: //g'`                                                                                      
        if [ $first -eq 0 ]                                                                                                                                                                  
        then                                                                                                                                                                                    
                echo -e "\t,\n"                                                                                                                                                                 
        fi
        first=0

        echo -e "\t{\n"
        echo -e "\t\t\"{#IMGPATH}\":\"$diskImage\",\n"
        echo -e "\t\t\"{#IMGFMT}\":\"$fileExtension\"\n"
        echo -e "\t}\n"
done

echo -e "\t]\n"
echo -e "}\n"

}

# Return file virtual size
virstualSize() {
        diskImage=$1

        /usr/bin/qemu-img info $diskImage | grep 'virtual size' | sed -e 's/.*(//' -e 's/ .*$//'

}

# Return file real size
realSize() {

        diskImage=$1

        ls -l $diskImage | awk '{ print $5 }'
}

# Help message
usage()  {
        echo -e "Script for virtual machines disk images monitoring"
        echo -e "Usage options"
        echo -e "\t-p <pathToFile>\tpath to VM's disk image"
        echo -e "\t-s\tvirtual size"
        echo -e "\t-r\treal size"
        echo -e "\t-d\tzabix discovery"
        echo -e "\t-h\t\tthis text"
}


filePath=""
discovery=0
virtual=0
real=0
getoptsRunned=0

while getopts ":p:vrd" opt
do
        case "${opt}" in
                p)
                        filePath=$OPTARG
                        ;;
                v)
                        virtual=1
                        ;;
                r)
                        real=1
                        ;;
                d)
                        discovery=1
                        ;;
                *)
                        usage
                        exit 1
                        ;;
        esac
        getoptsRunned=1
done


if [ $getoptsRunned -eq 0 ]
then
        usage
        exit 1
fi

if [ $virtual -eq 1 -o $real -eq 1 ]
then
        if [ "$filePath" == "" ]
        then
                echo "Need path to file"
                usage
                exit 1
        fi
fi

if [ $discovery -eq 1 ]
then
        disksList
fi

if [ $virtual -eq 1 ]
then
        virstualSize $filePath
fi

if [ $real -eq 1 ]
then
        realSize $filePath
fi

