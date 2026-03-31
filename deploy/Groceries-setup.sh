#!/usr/bin/env bash


# $1 : working dir
prepare_app_build() {
    # pushd $1 > /dev/null

    rm -r scripts 2> /dev/null # sanity check
    unzip archive.tar.gz.zip
    tar -xvf archive.tar.gz

    cp *-key.json ./scripts
    cp .env ./scripts

    rm ./scripts/.gitattributes # don't know why this gets archived

    pushd ./scripts > /dev/null
    bundle install
    popd > /dev/null

    create_helper_script
    #popd > /dev/null
}

# $1 : destination folder
create_helper_script() {
    sc=$(cat <<EOF
#!/data/data/com.termux/files/usr/bin/bash

pushd ~/.termux/tasker/groceries > /dev/null
SSL_CERT_DIR=${SSL_CERT_DIR} SSL_CERT_FILE=${SSL_CERT_FILE} bundle exec ruby driver.rb \$1
popd > /dev/null

rm /data/data/com.termux/files/home/storage/shared/Documents/Xfer/copied-*
EOF
)
    if [ "$verbose" == "1" ]; then
        echo "$sc"
    fi
    echo "$sc" > groceries.sh
    chmod +x groceries.sh
}

# $1 : working folder
# $2 : destination folder
move_app_to_destination() {
    mkdir -p $2/groceries && cp -a $1/scripts/. $2/groceries
}
