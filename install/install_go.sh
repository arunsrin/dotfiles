set -x
set -e

GO_VERSION="1.16.5"

# I like to keep things in ~/packages
mkdir -p ~/packages

if [ ! -f "/home/arunsrin/packages/go"$GO_VERSION".linux-amd64.tar.gz" ]; then
	echo "go archive not found, downloading"
	wget https://golang.org/dl/go"$GO_VERSION".linux-amd64.tar.gz -O ~/packages/go"$GO_VERSION".linux-amd64.tar.gz
else
	echo "go archive found, skipping download"
fi

rm -rf ~/packages/go && tar -C ~/packages -xzf ~/packages/go"$GO_VERSION".linux-amd64.tar.gz


