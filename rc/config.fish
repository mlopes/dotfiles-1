if status --is-login
	for p in /usr/bin /usr/local/bin /opt/local/bin ~/bin ~/.config/fish/bin ~/bin/dotfiles/scripts ~/.cabal/bin ~/.xmonad/bin ~/.gem/ruby/1.9.1/bin ~/bin/nest/bin
		if test -d $p
			set PATH $p $PATH
		end
	end
end


set PATH ~/.rbenv/shims $PATH

set fish_greeting ""
set -x CLICOLOR 1
set -x EDITOR vim
set -x BROWSER chromium-browser


function fish_prompt -d "Write out the prompt"
	# printf '%s%s@%s%s' (set_color brown) (whoami) (hostname|cut -d . -f 1) (set_color normal) 

    # Color writeable dirs green, read-only dirs red
    if test -w "."
        printf ' %s%s' (set_color 8A7) (prompt_pwd)
    else
        printf ' %s%s' (set_color red) (prompt_pwd)
    end

    set gitinfo (git_cwd_info)
    if [ ! -z "$gitinfo" ]
        printf ' %s' "$gitinfo"
    end

	printf '%s [%s]%s> ' (set_color 97A) (date +%H:%M) (set_color normal)
end

alias !=xdg-open
alias !bev='bundle exec vagrant'

function git -d "git wrapper"
    set -l p (pwd)
    while test "$p" != "$HOME" -a "$p" != "/" ;
        if test -e "$p/.gitemail"
            set -x GIT_AUTHOR_EMAIL (cat "$p/.gitemail")
            set -x GIT_COMMITTER_EMAIL (cat "$p/.gitemail")
            break
        end
        set -l p (dirname "$p")
    end
    /usr/bin/git $argv
end

alias g=git

