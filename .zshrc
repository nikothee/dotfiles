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

alias njust="just --justfile ${HOME}/Documents/.Justfile"

export VISUAL=vim
export EDITOR="$VISUAL"

export KUBECONFIG=~/.kube/config

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# so I can use my work yubikey with ssh
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

################################################################################
### starship prompt

eval "$(starship init zsh)"

################################################################################

. "$HOME/.local/bin/env"