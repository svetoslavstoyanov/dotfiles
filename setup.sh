curl https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/refs/heads/master/print.sh
source ./printh.sh

curl https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/refs/heads/master/create-user.sh

chmod +x ./create-user.sh
./create-user.sh

curl https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/refs/heads/master/setup-dev.sh

chmod +x ./setup-dev.sh

rm -rf ./print.sh ./create-user.sh ./setup-dev.sh
