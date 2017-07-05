abort() {
  >&2 echo "$@"
  exit 1
}

test -n "$HOME" || abort "\$HOME must be defined"
test -n "$USER" || abort "\$USER must be defined"

SSH_PUBLIC_KEY_FILE=$HOME/.ssh/id_rsa.pub
SSH_KNOWN_HOSTS_FILE=$HOME/.ssh/known_hosts
SSH_AUTHORIZED_KEYS_FILE=$HOME/.ssh/authorized_keys

test -f $SSH_PUBLIC_KEY_FILE \
  && echo "$SSH_PUBLIC_KEY_FILE exists" \
  || { \
    echo "generating ssh key for $USER" \
    && ssh-keygen -t rsa -b 1024 -N '' -C $USER -f $HOME/.ssh/id_rsa \
    || abort "could not generate ssh key for $USER" \
  ; }

SSH_PUBLIC_KEY="$(head -n 1 $SSH_PUBLIC_KEY_FILE)"

echo "adding localhost to ssh known hosts" \
  && ssh-keyscan -H localhost 2>/dev/null > $SSH_KNOWN_HOSTS_FILE \
  || abort "could not add localhost to ssh known hosts for $USER"

grep -q "$SSH_PUBLIC_KEY" $SSH_AUTHORIZED_KEYS_FILE 2>/dev/null \
  && echo "ssh key already authorized" \
  || { \
    echo "adding ssh key to authorized key" \
    && echo "$SSH_PUBLIC_KEY" >> $SSH_AUTHORIZED_KEYS_FILE \
    || abort "could not add ssh key to authorized keys for $USER" \
  ; }
