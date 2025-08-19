#!/usr/bin/env bash

# there are manual steps for a device:
#  1 - download and set up the id_ed25519 key
#  2 - download and execute this script on device

cleanup() {
    rm -r $1
}

usage() {
    echo "Usage $0 [-v] -w working directory -d destination directory"
}

# $1 : working folder
setup_working_dir() {
    if [ ! -d $1 ]; then
        mkdir -p $1 > /dev/null
    else
        rm -r $1/* 2> /dev/null
        rm -r $1/.* 2> /dev/null
    fi

    pushd $1 > /dev/null

    if [ ! -f download_artifact.rb ]; then
        wget -q https://raw.githubusercontent.com/csolallo/Groceries/refs/heads/main/deploy/download_artifact.rb
    fi
    if [ ! -f parse_token_file.awk ]; then
        wget -q https://raw.githubusercontent.com/csolallo/Groceries/refs/heads/main/deploy/parse_token_file.awk
    fi

    # download keys from github (you'll need the id_ed25519 ssh deploy key set up)
    git clone git@github.com:csolallo/Keys-and-Tokens.git
    mv ./Keys-and-Tokens/Groceries/* ./Keys-and-Tokens/Groceries/.* .


    rm -rf ./Keys-and-Tokens

    download_token=$(awk -f parse_token_file.awk -v token=archive-download tokens.txt)
    if [ "$verbose" == "1" ]; then
        echo "$download_token"
    fi
    TOKEN="$download_token" SSL_CERT_DIR="/data/data/com.termux/files/usr/etc/tls" SSL_CERT_FILE="/data/data/com.termux/files/usr/etc/tls/cert.pem" ruby ./download_artifact.rb

    popd

    if [ ! -f $1/archive.tar.gz.zip ]; then
        return 1
    fi
}

# $1 : working dir
build_script_folder() {
    pushd $1 > /dev/null

    rm -r scripts 2> /dev/null # sanity check
    unzip archive.tar.gz.zip
    tar -xvf archive.tar.gz

    cp *-key.json ./scripts
    cp .env ./scripts

    rm ./scripts/.gitattributes # don't know why this gets archived

    pushd ./scripts > /dev/null
    bundle install
    popd > /dev/null

    popd > /dev/null
}

# $1 : working folder
# $2 : destination folder
move_to_destination() {
    mkdir -p $2/bin && cp -a $1/scripts/. $2/bin
}

# $1 : destination folder
create_helper_script() {
    pushd $1 > /dev/null

    sc=$(cat <<EOF
#!/usr/bin/env bash

pushd ./bin > /dev/null
SSL_CERT_DIR=/usr/lib/ssl SSL_CERT_FILE=/usr/lib/ssl/cert.pem bundle exec ruby driver.rb \$1
popd > /dev/null
EOF
)
    echo "$sc" > runner.sh
    chmod +x runner.sh

    popd > /dev/null
}

while getopts "w:d:hv" opt; do
    case "$opt" in
        w) 
        working=$OPTARG
        ;;
        d)
        dest=$OPTARG
        ;;
        v)
        verbose=1
        ;;
        h)
        usage
        exit 0
        ;;
    esac
done

if [ -z "$working" -o -z "$dest" ]; then
    exit -1
fi

echo "Step 1: download scripts, artifact, and keys into working folder" 
echo "----------------------------------------------------------------"
setup_working_dir "$working"
if [[ $? -ne 0 ]]; then
   cleanup "$working"
   exit -1
fi

echo "Step 2: download gem dependencies"
echo "----------------------------------------------------------------"
build_script_folder "$working"

echo "Step 3: move script folder to destination directory"
echo "----------------------------------------------------------------"
move_to_destination "$working" "$dest"
create_helper_script "$dest"
echo "Done"

cleanup "$working"

