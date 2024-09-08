# provision-vagrant

## Easily create and provision new Ruby on Rails Vagrant VM dev boxes

The `provision-vagrant` gem works in conjunction with [Vagrant by HashiCorp](https://www.vagrantup.com/) to let you easily spin up new Vagrant Virtual Machines--such as one pre-configured to include all of the necessary software to build a Ruby on Rails application.

## Why?

As a macOS user that targets deployment to Ubuntu machines in the cloud, having a local linux VM for development for each separate project has the following benefits:

- Versioning: it is never a problem if different apps need different versions of ruby, rails, postgres, etc.
- Custom additions: what if you work on App A that needs redis v7, and App B that needs redis v6--this is never an issue with separate VMs.
- Compatibility with target deployment environment--this was more important prior to the advent of Docker, but still comes in handy sometimes.

*Why not just use Docker?*

Docker is great. It is a good alternative for setting up all of the related services a Ruby on Rails app needs, like PostgreSQL, redis, etc. But I would argue that it is _not_ great for actual development of Rails apps. You have to restart too often; there are file syncing issues; and the restart/rebuild loop can just be too slow at times.

## Installation

The `provision-vagrant` gem won't do much without first having Vagrant installed:

[https://developer.hashicorp.com/vagrant/downloads](https://developer.hashicorp.com/vagrant/downloads)

You will need virtual machine software as well (such as VirtualBox), which vagrant uses to create new boxes:

[https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)

Once you have these installed, you can proceed with installing the `provision-vagrant` gem:

```
gem install provision-vagrant
```

This should install a `provision-vagrant` command that you can now. To test it:

```
provision-vagrant -v
```

If it shows you the version number of the gem, you should be ready to proceed.

## Usage

### Initialization

The `provision-vagrant` gem needs to be initialized before it can be used. Initialize it with:

```
provision-vagrant -i
```

All this does is copy three template files over to your user directory:

```
~/Vagrantfile.template
~/provision-vagrant.post-hook.sh
~/provision-vagrant.yml
```

Next you will want to take a look at those files and customize them to your liking.

By default, they setup a standard Ruby on Rails development environment with the following features:

- Ubuntu Linux 24.04 VM
- rbenv (latest version)
- Ruby 3.3.5
- NodeJS 22 & Yarn
- PostgreSQL 16
- Copies your id_rsa keys from ~/.ssh/ over to the VM
- Github is configured with the same name/email from your host machine
- PostgreSQL is configured to allow the `vagrant` user to create databases

This setup is 100% modifiable. Simply update the generated files in your ~/ directory. These are never touched by `provision-vagrant` once it has been initialized.

### Usage - Generating New VM Boxes

The `provision-vagrant` gem can now be used to generate boxes with:

```
provision-vagrant new-box-name
```

This creates some directories and copies over the Vagrantfile.template after interpolating variables within it:

```
Created directory: ~/new-box-name/
Created directory: ~/new-box-name/dev-box/
Interpolated & copied ~/Vagrantfile.template over to: ~/new-box-name/dev-box/Vagrantfile
```

### Usage - Provisioning

Your new box is now ready to be provisioned by vagrant. Do so with:

```
cd ~/new-box-name/dev-box/
vagrant up
```

Look through the `config.vm.provision` section in ~/Vagrantfil.template to see what is happening here.

Once complete, you can ssh into your new box as per usual:

```
vagrant ssh
```

But next, you'll want to run the `provision-vagrant` post-hook bash script to finsih setting everything up.

```
./provision-vagrant.post-hook.sh
```

NOTE: you'll want to run this *inside* the VM after logging in via SSH.

This step is necessary as vagrant provisioning cannot handle piping commands into new bash shells, etc--which is how `rbenv` is typically installed.

At the end of the provisioning, version numbers for installed programs/libraries are displayed, and you will be prompted to accept the authenticity of the github.com host. This is just a test to see if your SSH connection to github.com is working and your ~/.ssh/id_rsa* keys have been copied over correctly.

If you see something like this after accepting the authenticity request:

```
Hi <your-github-username>! You've successfully authenticated, but GitHub does not provide shell access.
```

... you should be ready to go!

## Next Steps

While still logged into your new VM, try installing rails and generating a new rails app:

```
gem install rails
rails new --database=postgresql my-new-app
```

You should be able to do things like create the databases with ease:

```
cd my-new-app
rails db:create
```

Hopefully it was smooth sailing. You should now be ready to rock & roll, with the ability to create new vagrant VMs for every new project with ease.

## Contributing

In the event that you'd like to contribute to `provision-vagrant` -- we follow the "fork-and-pull" git workflow

- Fork the repository to your own GitHub account
- Clone the project to your machine
- Create a branch locally with a succinct but descriptive name
- Commit changes to the branch
- Push changes to your fork
- Open a PR in this repository from your forked branch
