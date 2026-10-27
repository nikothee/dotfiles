################################################################################
### oh-my-zsh configs

export ZSH="$HOME/.oh-my-zsh"

plugins=(
  aws
  docker
  fluxcd
  gcloud
  git
  helm
  kubectl
  podman
  rust
  toolbox
  fzf-tab
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

################################################################################
### user configs

export VISUAL=vim
export EDITOR="$VISUAL"

export KUBECONFIG=~/.kube/config

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# so I can use my work yubikey with ssh
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

################################################################################
### aliases

alias docker="podman"
alias njust="just --justfile ${HOME}/Documents/.Justfile"

dockerSHA() {
  skopeo inspect --format '{{.Digest}}' "docker://$1"
}

################################################################################
### starship prompt

eval "$(starship init zsh)"

################################################################################

. "$HOME/.local/bin/env"
