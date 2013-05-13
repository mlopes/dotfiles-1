if status --is-login
	for p in /usr/bin /usr/local/bin /opt/local/bin ~/bin ~/.config/fish/bin 
		if test -d $p
			set PATH $p $PATH
		end
	end
end



set fish_greeting ""
set -x CLICOLOR 1

function fish_prompt -d "Write out the prompt"
	# printf '%s%s@%s%s' (set_color brown) (whoami) (hostname|cut -d . -f 1) (set_color normal) 

    # Color writeable dirs green, read-only dirs red
    if test -w "."
        printf ' %s%s' (set_color green) (prompt_pwd)
    else
        printf ' %s%s' (set_color red) (prompt_pwd)
    end

    set gitinfo (git_cwd_info)
    if [ ! -z "$gitinfo" ]
        printf ' %s' "$gitinfo"
    end

	printf '%s> ' (set_color normal)
end


bind \cr "rake"

function ss -d "Run the script/server"
	script/server
end

function sc -d "Run the Rails console"
	script/console
end

if test -d "/opt/java"
   set -x JAVA_HOME "/opt/java"
end

# yarrr, add /var/lib/gems/1.8/bin to path so gems installed by the retarded ubuntu rubygems package are on the path
set CUSTOM_GEM_PATH "/var/lib/gems/1.8/bin"
if test -d $CUSTOM_GEM_PATH
    set -x PATH $PATH "/var/lib/gems/1.8/bin"
end


# Load custom settings for current hostname
set HOST_SPECIFIC_FILE ~/.config/fish/(hostname).fish
if test -f $HOST_SPECIFIC_FILE
   . $HOST_SPECIFIC_FILE
else 
   echo Creating host specific file: $HOST_SPECIFIC_FILE
   touch $HOST_SPECIFIC_FILE
end
   
# Load custom settings for current user
set USER_SPECIFIC_FILE ~/.config/fish/(whoami).fish
if test -f $USER_SPECIFIC_FILE
   . $USER_SPECIFIC_FILE
else
   echo Creating user specific file: $USER_SPECIFIC_FILE
   touch $USER_SPECIFIC_FILE
end

# Load custom settings for current OS
set PLATFORM_SPECIFIC_FILE ~/.config/fish/(uname -s).fish
if test -f $PLATFORM_SPECIFIC_FILE
   . $PLATFORM_SPECIFIC_FILE
else
   echo Creating platform specific file: $PLATFORM_SPECIFIC_FILE
   touch $PLATFORM_SPECIFIC_FILE
end  


