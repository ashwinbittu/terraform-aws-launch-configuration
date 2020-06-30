#!/bin/bash    

apt-get update
apt-get -y install nginx
apt-get -y install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "AWS_KEY--->" ${AWS_KEY}
echo "AWS_SEC--->" ${AWS_SEC}

aws configure set aws_access_key_id ${AWS_KEY}
aws configure set aws_secret_access_key ${AWS_SEC}
aws configure set default.region ${AWS_REG}
devc=${DEVICE}
appver=${APP_VER}

isempty=$(file -s $devc)

if [[ $isempty == *": data"* ]]; then
    echo "is empty"
    uuid=""
    #mkfs -t xfs $devc
    mkfs.ext4 $devc
    mkdir -p /data
    mount $devc /data
    blkid > mntids.txt
    while read mntids; do
       if [[ $mntids == *"$devc"* ]]; then
              #uuid=$(mntids##*UUID=\")
              #uuid=$(uuid%%\"*)              
              uuid=$(awk -F '"' '{for (i=1; i<NF; i+=2) if ($1 ~ /UUID=$/) {print $(i+1); break}}' <<< $mntids)
              echo $uuid
       fi
       if [ ! -z "$uuid" ]; then
           break
       fi
    done < mntids.txt
    rm -rf mntids.txt
    if [ ! -z "$uuid" ]; then
        #echo "UUID=$uuid /data  xfs  defaults,nofail  0  2" >> /etc/fstab
        echo "$devc /data auto noatime 0 0" | sudo tee -a /etc/fstab
        cd /data
        aws s3 cp s3://citi-samplelapp/rel-$appver.zip .
        unzip rel-$appver.zip
        rm -rf rel-$appver.zip
        sed 's/root \/var\/www\/html;.*/root \/data;/' /etc/nginx/sites-enabled/default > default
        mv default  /etc/nginx/sites-enabled/
        systemctl restart nginx
    fi
else
    echo "not empty"
    mkdir /data
    mount $devc /data
    sed 's/root \/var\/www\/html;.*/root \/data;/' /etc/nginx/sites-enabled/default > default
    mv default  /etc/nginx/sites-enabled/
    systemctl restart nginx
fi