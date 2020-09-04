#!/usr/bin/env bash

# logging
function e_header() { echo -e "\n\033[1m$@\033[0m"; }

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `freshinstall` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

cd ~/.dotfiles

# install homebrew if not already there
if [[ ! "$(type -P brew)" ]]; then
    e_header '🍳 Installing homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

e_header '🍳 Updating homebrew'
brew doctor
brew update

brew install dialog

if ( ! dialog --yesno "Do you want to install ingvi's ❣ .dotfiles?" 6 30) then
    return;
fi;

# tap Brew Bundle
e_header '📚 Installing Bundle'
brew tap Homebrew/bundle

e_header '🍎 Installing Mas'
brew install mas

e_header '🍏 Enter your apple id, followed by [ENTER]:'
read appleid
mas signin $appleid

e_header '💾 Installing Applications and command line tools'
# restore installed apps
brew bundle
sudo xcodebuild -license accept

# Remove outdated versions from the cellar.
brew cleanup

e_header '💾 Installed all apps and tools from Brewfile'

e_header '💾 Creates mackup config file'
# makes sure mackup config is correct before restoring backup
cat >~/.mackup.cfg <<'EOT'
[storage]
engine = google_drive

[applications_to_ignore]
skype

[configuration_files]
.gitignore_global
.bash_profile

EOT

e_header '📦 Restores configs from mackup'
e_header '⌛ have a coffee this will take a while'
# restore mackup backup
mackup restore

e_header '💾 Creates a backup of you current .bash_profile'
# backup .bash_prfole
cat ~/.bash_profile > ~/.bash_profile.backup


e_header '🖌 Creates a new .bash_profile'
# create new bash profile
cat >~/.bash_profile <<'EOT'
#  Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.dotfiles/.{export,bash_profile,alias,function}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# say -v "Zarvox" "hello {$USER}, I'm a new terminal" &
# Show archey on bootup
# say -v "Zarvox" "new terminal" &
# archey -c
EOT

e_header '✅ Making sure you are using the latest node'
sudo n latest
sudo chown -R $USER /usr/local/n/

e_header '💪 Updates NPM'
npm update -g npm

e_header '🍉 Installing global node modules'

#node stuff
npm_globals=(
  @frctl/fractal@1.3.0
  node-inspector
  @frctl/fractal@1.3.0
  @vue/cli@4.0.5
  babel-eslint@10.0.2
  cowsay@1.4.0
  eslint@6.1.0
  gatsby-cli@2.7.28
  json-server@0.15.0
  netlify-cli@2.24.0
  npm@6.13.4
  parcel-bundler
  svgo
)

for npmglobal in "${npm_globals[@]}"
do
  npm install -g ${npmglobal};
done

e_header '✅ Makes sure you are using the most recent version of BASH'
sudo -s
echo /usr/local/bin/bash >> /etc/shells
chsh -s /usr/local/bin/bash

# Switch to using brew-installed bash as default shell
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

# make sure seeyouspacecowboy is called on EXIT
echo 'sh ~/.dotfiles/seeyouspacecowboy.sh; sleep 2' >> ~/.bash_logout

# Updates all apps and stuff
update

# Setup projects folder
if ( dialog --yesno "Do you wish to have a 'projects' folder?" 6 30) then
e_header '💾 Creating projects folder'
mkdir ~/projects/

# makes sure mackup config is correct before restoring backup
cat >/etc/apache2/users/${USER}.conf <<'EOT'
<Directory "/Users/$USER/Sites/">
	AllowOverride All
	Options Indexes MultiViews FollowSymLinks
	Require all granted
</Directory>
EOT

# loads the brand new bash_profile
source ~/.bash_profile

e_header '🍺 you did it! 🍺'

# byebye
. seeyouspacecowboy.sh
