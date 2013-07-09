This cookbook includes support for running tests via Test Kitchen (1.0). This has some requirements.

1. You must be using the Git repository, rather than the downloaded cookbook from the Chef Community Site.
2. You must have Vagrant 1.1 installed.
3. You must have a "sane" Ruby 1.9.3 environment.

Once the above requirements are met, install the additional requirements:

Install the berkshelf plugin for vagrant, and berkshelf to your local Ruby environment.

    vagrant plugin install vagrant-berkshelf
    gem install berkshelf

Install Test Kitchen 1.0 (unreleased yet, use the alpha / prerelease version).

    gem install test-kitchen --pre

Install the Vagrant driver for Test Kitchen.

    gem install kitchen-vagrant

Once the above are installed, you should be able to run Test Kitchen:

    kitchen list
    kitchen test

# A note about the SLES Box

The .kitchen.yml has a platform for SLES 11-sp2. Due to licensing
reasons, we cannot distribute the base box. You can however build your
own using the Bento definition `sles-11-sp2`, and import it separate
from test-kitchen's run.

Before exporting the box, do ensure that the vagrant user has
NOPASSWD: ALL in /etc/sudoers.

# A note about the OmniOS Box

This patch to test-kitchen is required to test using the OmniOS box,
as the path to `pkgadd` (`/usr/sbin`) is not in the default `vagrant`
user's path when logging in without a TTY.

https://github.com/opscode/test-kitchen/pull/164

If your local version of Vagrant is 1.2.0 or higher, you may need to
install the `vagrant-guest-omnios` plugin to get OS detection for
OmniOS to work properly.

https://github.com/clintoncwolfe/vagrant-guest-omnios

TL;DR:

    vagrant plugin install vagrant-guest-omnios
