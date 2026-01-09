curl https://github.com/svetoslavstoyanov/dotfiles/blob/master/print.sh
source ./printh.sh

curl https://github.com/svetoslavstoyanov/dotfiles/blob/master/create-user.sh

chmod +x ./create-user.sh
./create-user.sh

curl https://github.com/svetoslavstoyanov/dotfiles/blob/master/setup-dev.sh

chmod +x ./setup-dev.sh

rm -rf ./print.sh ./create-user.sh ./setup-dev.sh
