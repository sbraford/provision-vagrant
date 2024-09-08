#!/usr/bin/bash

echo "Executing ~/provision-vagrant.post-hook.sh ..."

echo "Setting .ssh/ file permissions ..."
chmod 700 /home/vagrant/.ssh/
chmod 600 /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub

echo "Configuring git..."
git config --global color.ui true
git config --global user.name {{github_name}}
git config --global user.email {{github_email}}

echo "Installing rbenv ..."
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.bashrc
echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bashrc
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
echo "gem: --no-document" > ~/.gemrc

echo "Installing a ruby ..."
/home/vagrant/.rbenv/bin/rbenv install {{ruby_version}}
/home/vagrant/.rbenv/bin/rbenv global {{ruby_version}}

echo "Installing bundler gem ..."
gem install bundler

echo "Adding ~/.bashrc customizations ..."
echo "alias rails-server='bundle exec rails s -b 0.0.0.0'" >> /home/vagrant/.bashrc

echo "Setting up PostgreSQL permissions to allow local access ..."
sudo su - postgres << EOF
sed -i 's/local   all             all                                     peer/local all all trust/g' /etc/postgresql/16/main/pg_hba.conf
psql -c "CREATE USER vagrant WITH ENCRYPTED PASSWORD 'password';"
psql -c "ALTER USER vagrant CREATEDB;"
psql -c "ALTER ROLE vagrant PASSWORD null;"
EOF

echo "Showing versions ..."
sudo systemctl status postgresql
node -v
yarn --version
ruby -v
gem -v
bundle -v

echo ""
echo "Authenticating with GitHub via ssh ..."
echo ""
echo "Now checking to see if we now have github SSH access via command: ssh -T git@github.com"
echo ""
ssh -T git@github.com
