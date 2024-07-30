#!/usr/bin/env zsh

setopt promptsubst

EXIT_SUCCESS_ICON=""
EXIT_FAILURE_ICON=""
EXIT_SUCCESS_COLOR="#33dd55"
EXIT_FAILURE_COLOR="#bb2211"

PROMPT_COLOR="#2a84d2"

GIT_COLOR_CLEAN="#33dd55"
GIT_COLOR_UNTRACKED="#ee4433"
GIT_COLOR_UNSTAGED="#FFA500"
GIT_COLOR_UNCOMMITED="#FFFF00"
GIT_COLOR_CURRENT=""

GIT_ICON_CLEAN=""
GIT_ICON_UNTRACKED=""
GIT_ICON_UNSTAGED=""
GIT_ICON_UNCOMMITED=""
GIT_ICON_CURRENT=""

SSH_USER_HOST_COLOR="#FFA500"

PROMPT='$(main_prompt)'
RPROMPT='$(exit_code) $(exec_time)'

exit_code() {
        if [ -n "$print_exitc" ]; then
                echo "%(?.%F{$EXIT_SUCCESS_COLOR}$EXIT_SUCCESS_ICON (%?%)%f.%B%F{$EXIT_FAILURE_COLOR}$EXIT_FAILURE_ICON (%?%)%b%f)"
        fi
}

main_prompt() {
        echo "%F{$SSH_USER_HOST_COLOR}$(ssh_connection)%f%F{$PROMPT_COLOR}$(print_dir)%f$(git_status)%F{$PROMPT_COLOR} %f "
}

ssh_connection() {
        [ -z "$SSH_CONNECTION" ] && exit
        echo -n "[%n@%M] "
}

print_dir() {
        echo "%B%~%b"
}

get_time() {
        echo "$(($(date +%s%N)/1000000))"
}

exec_time() {
        if [ ! -z "$time_exec" ]; then
                time="$(echo $time_finish - $time_exec | bc)"
                echo "%F{$PROMPT_COLOR} ${time}ms%f"
        fi
}

git_status() {
        [ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ] && exit

        if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
                GIT_ICON_CURRENT=$GIT_ICON_CLEAN
                GIT_COLOR_CURRENT=$GIT_COLOR_CLEAN
        elif [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
                GIT_ICON_CURRENT=$GIT_ICON_UNTRACKED
                GIT_COLOR_CURRENT=$GIT_COLOR_UNTRACKED
        elif ! git diff --exit-code --quiet; then
                GIT_ICON_CURRENT=$GIT_ICON_UNSTAGED
                GIT_COLOR_CURRENT=$GIT_COLOR_UNSTAGED
        elif ! git diff --cached --exit-code --quiet; then
                GIT_ICON_CURRENT=$GIT_ICON_UNCOMMITED
                GIT_COLOR_CURRENT=$GIT_COLOR_UNCOMMITED
        fi

        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        echo -n "%b%F{$GIT_COLOR_CURRENT} ( $branch $GIT_ICON_CURRENT )%f%b"
}

preexec() {
    cmd=$1
    time_exec=$(get_time)
}

precmd() {
    if [ ! "$cmd" ]; then 
        unset time_exec
        unset print_exitc
    else
        unset cmd
        print_exitc=true
        time_finish=$(get_time)
    fi
}
