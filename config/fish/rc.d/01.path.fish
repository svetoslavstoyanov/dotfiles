# Fish shell path setup

set -x DOTNET_ROOT "$HOME/.dotnet"
set -x PATH $PATH "$DOTNET_ROOT" "$DOTNET_ROOT/tools"
