set fish_greeting                                           # Suppresses fish's intro message.

### PROMPT ###
# Sashimi prompt from oh-my-fish
# https://github.com/isacikgoz/sashimi/blob/master/fish_prompt.fish

function fish_prompt
  set -l last_status $status
  set -l cyan (set_color -o cyan)
  set -l yellow (set_color -o yellow)
  set -g red (set_color -o red)
  set -g blue (set_color -o blue)
  set -l green (set_color -o green)
  set -g normal (set_color normal)

  set -l ahead (_git_ahead)
  set -g whitespace ' '

  if test $last_status = 0
    set initial_indicator "$green◆"
    set status_indicator "$normal❯$cyan❯$green❯"
  else
    set initial_indicator "$red✖ $last_status"
    set status_indicator "$red❯$red❯$red❯"
  end
  set -l cwd $cyan(basename (prompt_pwd))

  if [ (_git_branch_name) ]

    if test (_git_branch_name) = 'master'
      set -l git_branch (_git_branch_name)
      set git_info "$normal git:($red$git_branch$normal)"
    else
      set -l git_branch (_git_branch_name)
      set git_info "$normal git:($blue$git_branch$normal)"
    end

    if [ (_is_git_dirty) ]
      set -l dirty "$yellow ✗"
      set git_info "$git_info$dirty"
    end
  end

  # Notify if a command took more than 5 minutes
  if [ "$CMD_DURATION" -gt 300000 ]
    echo The last command took (math "$CMD_DURATION/1000") seconds.
  end

  echo -n -s $initial_indicator $whitespace $cwd $git_info $whitespace $ahead $status_indicator $whitespace
end

function _git_ahead
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' 2>/dev/null)
  if [ $status != 0 ]
    return
  end
  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead  (count (for arg in $commits; echo $arg; end | grep -v '^<'))
  switch "$ahead $behind"
    case ''     # no upstream
    case '0 0'  # equal to upstream
      return
    case '* 0'  # ahead of upstream
      echo "$blue↑$normal_c$ahead$whitespace"
    case '0 *'  # behind upstream
      echo "$red↓$normal_c$behind$whitespace"
    case '*'    # diverged from upstream
      echo "$blue↑$normal$ahead $red↓$normal_c$behind$whitespace"
  end
end

function _git_branch_name
  echo (command git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty 2>/dev/null)
end
### END OF PROMPT ###


### SPARK ###
# https://github.com/jorgebucaran/spark.fish/blob/main/functions/spark.fish

function spark --description Sparklines
    argparse --ignore-unknown --name=spark v/version h/help m/min= M/max= -- $argv || return

    if set --query _flag_version[1]
        echo "spark, version 1.1.0"
    else if set --query _flag_help[1]
        echo "Usage: spark <numbers ...>"
        echo "       stdin | spark"
        echo "Options:"
        echo "       --min=<number>   Minimum range"
        echo "       --max=<number>   Maximum range"
        echo "       -v or --version  Print version"
        echo "       -h or --help     Print this help message"
        echo "Examples:"
        echo "       spark 1 1 2 5 14 42"
        echo "       seq 64 | sort --random-sort | spark"
    else if set --query argv[1]
        printf "%s\n" $argv | spark --min="$_flag_min" --max="$_flag_max"
    else
        command awk -v min="$_flag_min" -v max="$_flag_max" '
            {
                m = min == "" ? m == "" ? $0 : m > $0 ? $0 : m : min
                M = max == "" ? M == "" ? $0 : M < $0 ? $0 : M : max
                nums[NR] = $0
            }
            END {
                n = split("▁ ▂ ▃ ▄ ▅ ▆ ▇ █", sparks, " ") - 1
                while (++i <= NR)
                    printf("%s", sparks[(M == m) ? 3 : sprintf("%.f", (1 + (nums[i] - m) * n / (M - m)))])
            }
        ' && echo
    end
end
### END OF SPARK ###

### BANG BANG "!!" FUNCTIONALITY ###
### Only works in emacs mode, not vi mode. ###
# https://github.com/oh-my-fish/plugin-bang-bang/blob/master/functions/__history_previous_command.fish
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end
# https://github.com/oh-my-fish/plugin-bang-bang/blob/master/functions/__history_previous_command_arguments.fish
function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end
### END OF BANG BANG ###

### FUNCTIONS ###

### Skip Function
# For ignoring the firs 'n' lines
# ex. seq 10 | skip 5
# results: prints everything but the first 5 lines
function skip --argument n
    tail +(math 1 + $n)
end

### Take Function
# For taking the first 'n' lines
# ex: seq 10 | take 5
# results: prints only the first 5 lines
function take --argument number
    head -$number
end

### Fish Greeting
# Greet with current weather
#function fish_greeting
#    weather-Cli get Chestermere | skip 1 | lolcat
#end

### END FUNCTIONS ###

### ALIASES ###

# Spark aliases
alias clear='/bin/clear; echo; echo; seq 1 (tput cols) | sort -R | spark | lolcat; echo; echo'

# Ask for confirmations when altering files
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Better ls
alias ls='exa -al  --group-directories-first --color=always'

# Express VPN aliases
alias evpn='evpn.zsh'
alias ev='evpn.zsh'

# Up directories
alias ..='cd ..'

# Create parent directories with mkdir
alias mkdir='mkdir -pv'

# Add battery widget to btm
alias btm='btm --battery'

# Rck-Roll Alias
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# Use BAT for CAT
alias cat='bat'

# Git Alias (for git --bare dotfile repo)
#
#   git init --bare $HOME/dotfiles
#   alias gitdotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME' (add this alias to .bashrc)
#   bash
#   gitdotfiles config --local status.showUntrackedFiles no
#
#   Basic usage example:
#
#   gitdotfiles add /path/to/file
#   gitdotfiles commit -m "A short message"
#   gitdotfiles push

alias gitdotfiles='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'



### PRE-EXISTING ###
# This was already here.

if status is-interactive
    # Commands to run in interactive sessions can go here
end

### INITIALIZE ###
# Clear to get colour bars.
clear
# Display weather
weather-Cli get Mississauga | skip 1 | lolcat
# Run DT's color scripts
# https://gitlab.com/dwt1/shell-color-scripts
colorscript random

starship init fish | source

set -Ux FREEPLANE_USE_UNSUPPORTED_JAVA_VERSION 1
