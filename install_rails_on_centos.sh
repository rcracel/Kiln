yum update -y

yum groupinstall "Development Tools"

yum install rubygems

useradd -m -s /bin/bash rails

su - rails

git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

exec $SHELL -l


rbenv install 1.9.3-p327

rbenv rehash

rbenv global 1.9.3-p327


exit # back to root

yum install rubygems

gem install rubygems-update

update_rubygems

gem install rake
gem install bundler

rbenv rehash

git clone https://github.com/rails/rails.git
cd rails
$ bundle

# follow instructions on http://wiki.nginx.org/Install

gem install passenger

passenger-install-nginx-module

