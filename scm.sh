#!/usr/bin/env bash

# #########################################################
#    Version Control 

# Source Control Git
alias git_tree='git log --branches --remotes --tags --graph --pretty=format:"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
alias git_local_only_branches='git branch -vv | cut -c 3- | awk '"'"'$3 !~/\[/ { print $1 }'"'"'| sort -f' # Show Local Only Branches (those that dont exist in origin/remote)

# alias nah='git reset --hard; git clean -df' # Gone forever - Reset to last commit and remove untracked files and directories.
alias nah='try nope - nah is too dangerous'

# Recover with git reflog - Reset to last commit and remove untracked files and directories.
alias nope='git reset --hard'

# git alias
git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.credentials.helper "config --get-all --show-origin credential.helper"

# debug git
alias git_debug="GIT_TRACE=true \
GIT_CURL_VERBOSE=true \
GIT_SSH_COMMAND=\"ssh -vvv\" \
GIT_TRACE_PACK_ACCESS=true \
GIT_TRACE_PACKET=true \
GIT_TRACE_PACKFILE=true \
GIT_TRACE_PERFORMANCE=true \
GIT_TRACE_SETUP=true \
GIT_TRACE_SHALLOW=true \
git $@"


function init_global_gitignore() {
    # ensure the default ignores are in place - no need to add these to each project's .gitignore
    git config --global core.excludesfile  ~/.bash/.global.gitignore
}
init_global_gitignore


# alias git_tag_history='~/bin/tag_history.sh' # generate git tag history


function git_tag_relases_with_recent_commits() {
    # TODO _ THIS NEEDS WORK - duplicates appearing
    lastn="${1:-5}" # default to last 5 commits before TAG
    git for-each-ref --sort=creatordate --shell --format="ref=%(refname:short)
	obj=%(objectname:short)
	subj=%(*subject)" refs/tags | while read entry; do
    eval $entry;
    echo "

## $ref

**Released:** `git log -1 --date=format:'%Y %h %d' --format="%cd" $obj` ($obj)

$(git log -$lastn --date=format:'%Y %h %d' --format="  - %s" $obj)
"
done

}


function git_tag_relases() {
    git for-each-ref --sort=-creatordate --format '## %(refname)

**Released:**  %(creatordate) %(object:short) - %(*objectname:short)

   -  %(*subject)

' refs/tags | sed -e 's-refs/tags/--'

}

function git_tag_date_hash() {
    # git_tag_date_hash
     git for-each-ref --sort=creatordate --shell --format="ref=%(refname:short)
     obj=%(objectname:short)" refs/tags | while read entry;do eval $entry;echo "$ref,`git log -1 --date=format:'%Y %h %d' --format="%cd" $obj` ($obj)"| column -t -x -s ','; done
}

function git_tag_history() {
    [ $# -ne 2 ] && { echo "Usage: TAG_FROM TAG_TO"; return 1; }
    # show log entries between two tags
    git log ${1}...${2} --date=format:'%Y %h %d' --format="  - %s
    %an - %cd
"
}