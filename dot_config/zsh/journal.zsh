_journal_pull() {
  local journal_directory=$1

  git -C "$journal_directory" pull --quiet && return 0

  print -u2 "journal-edit: git pull failed in $journal_directory"
  read -q "?Open the journal without the latest remote entries? [y/N] "
  local answer=$?
  print
  return $answer
}

_journal_last_entry_excluding() {
  local excluded_date=$1 journal_directory=$2
  local -a dated_entries other_entries

  dated_entries=("$journal_directory"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].*.gpg(N))
  other_entries=(${dated_entries:#*/${excluded_date}.*})

  print -r -- "${other_entries[-1]}"
}

_journal_create_entry() {
  local entry_date=$1 entry_path=$2

  printf '# %s\n\n' "$entry_date" |
    gpg --batch --quiet --encrypt --default-recipient-self --output "$entry_path" && return 0

  rm -f "$entry_path"
  print -u2 "journal-edit: could not encrypt $entry_path with your GPG key"
  return 1
}

_journal_unlock_gpg_key() {
  local encrypted_path=$1

  gpg --quiet --decrypt "$encrypted_path" > /dev/null && return 0

  print -u2 "journal-edit: could not decrypt $encrypted_path with your GPG key"
  return 1
}

journal-edit() {
  local journal_directory="$HOME/projects/personal/journal"
  local today today_entry last_entry
  local -x GPG_TTY="${GPG_TTY:-$TTY}"

  if [[ ! -d "$journal_directory" ]]; then
    print -u2 "journal-edit: journal directory not found: $journal_directory"
    return 1
  fi

  today=$(date +%Y-%m-%d)
  today_entry="$journal_directory/$today.md.gpg"

  _journal_pull "$journal_directory" || return 1
  last_entry=$(_journal_last_entry_excluding "$today" "$journal_directory")

  if [[ ! -e "$today_entry" ]]; then
    _journal_create_entry "$today" "$today_entry" || return 1
  fi
  _journal_unlock_gpg_key "$today_entry" || return 1

  if [[ -n "$last_entry" ]]; then
    nvim -O "$last_entry" "$today_entry" -c 'wincmd l' -c 'normal! G'
  else
    nvim "$today_entry" -c 'normal! G'
  fi
}
