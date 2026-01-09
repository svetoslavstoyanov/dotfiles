source <(curl -fsSL https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/refs/heads/master/print.sh)>

curl -fsSL https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/refs/heads/master/create-user.sh | bash


#chmod +x ./create-user.sh
#./create-user.sh

curl -fsSL https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/refs/heads/master/setup-dev.sh | bash

#chmod +x ./setup-dev.sh

#rm -rf ./print.sh ./create-user.sh ./setup-dev.sh
