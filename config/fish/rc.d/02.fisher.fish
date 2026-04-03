# Fisher plugin manager setup

# Install Fisher if not present
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
end

# Install plugins
fisher install jorgebucaran/git
fisher install jorgebucaran/docker
fisher install edc/bass  # for running bash scripts
# Note: Fish has built-in autosuggestions, syntax highlighting, and completions
