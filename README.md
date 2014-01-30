# Basic boxen

I wrote basic boxen to give me a consistent baseline environment to deploy apps
(mostly rails apps) to. I wanted an environment that was consistent across all my projects, yet
flexible enough to handle whatever apps I could throw at it. Basic boxen does just
that -- it's an opinionated set of chef cookbooks and default configs that gives
you a great development environment, while laying the groundwork for
sustainable growth into production. Using basic boxen in tandem with a simple
[Capistrano](http://capify.org) based deployment (such as the
examples provided herein) in your apps provides a wonderful and simple way to go
from zero to running application with minimal hassle and no lock-in.

# Getting started

## Installing basic boxen on your local machine

Before you can use basic boxen to build boxes, you have to tell it a little bit
about yourself. To do this, first clone this repo to your local machine and make
sure you have all the local gems and cookbooks installed:

    git clone git@github.com:mtrudel/basicboxen.git
    cd basicboxen
    bundle install
    bundle exec knife solo init .
    bundle exec berks install

Next you'll want to edit (and probably commit) the `nodes/all_in_one.json` file
and make the following changes. The contents of this file will be used to build
out external servers via knife solo commands.

* **Line 11**: Specify the address that root's email is forwarded to
* **Line 18**: Add your ssh public key (ie: the contents of your `~/.ssh/id_[dr]sa.pub` file)
  into the `ssh_keys` array

That's it! You're now ready to start making servers.

## Making a box

Now that you've made basic boxen your own, you can provision any number of boxes from this 
recipe by running:

    bundle exec knife solo bootstrap user@host nodes/all_in_one.json

In theory basic boxen can provision any remote box, even ones with packages already 
installed and running. In practice however, it makes more sense to run basic boxen against 
a newly installed remote machine. Ideally, basic boxen will be the first thing that's ever 
run on the machine. Most VM containers will automatically install sshd, provide you initial
login credentials, and set the hostname, so basic boxen takes those steps as
a given (note that you'll want to substitute the name of this initial user in
place of 'user' above)

#### Sidenote: Running basic boxen on an already provisioned box

Note that you only log in as your system's initial user the first time you run on the
remote server. The initial run of chef will create a `deploy` user, set them up
with passwordless sudo, and revoke root login via ssh, giving you a consistent
environment with the `deploy` user as the standard method of login. Because of
this, subsequent runs of knife should look like:

    bundle exec knife solo bootstrap deploy@host nodes/all_in_one.json

Unless you're making changes to your basic boxen fork, you shouldn't ever need
to run your configuration more than once (though it's totally safe to).

### What this gets you

Out of the box, basic boxen sets up your remote server to have:

* A running nginx instance with no hosts defined (and thus not bound anywhere)
* A domain socket only postgres server running, with 'peer' authentication
* Ruby 2.1.0 running inside rbenv, with the bundler gem installed
* A user 'deploy' with passwordless sudo and public-key only auth using your
  public key
* A postfix server running on localhost, with admin mail forwarded to your email
  address
* Basic admin stuff like logrotate, ntp, unattended upgrades, &c all running

This basic deployment has only SSH and NTP open to the world, and has a very
small attack surface exposed on SSH (all access is public key only, and root
login is disabled). Everything from here onwards is considered to be
a deployment concern, and can be well handled within your deployment tool of
choice (see below for a discussion of best practices with Capistrano based
deployment to a basic boxen).

### What does this *not* get you (yet)

This box is missing a few key pieces for production use. Most notably it does
not have:

* Realistic email forwarding (you'll probably want to use something like
  sendgrid or postmark in production)
* Any monitoring or backups configured
* Any performance tuning whatsoever on postgres
* Any other daemons such as redis, memcached, etc
* Any logical partitioning of services; everything is running on one machine

However, since basic boxen is built using chef it's easy to grow from here when
the time comes. Basic boxen is really meant to give you a basic starting point for 
getting started with projects while not hemming you in by early bad decisions. 
You can have a box up and running in a few minutes with basic boxen without
knowing anything about chef, and spend the time to grow out a more mature
production config on the same tooling when the time comes.

### How I use basic boxen

For reference, my personal workflow with basic boxen is this:

1. Spin up a new [DigitalOcean](https://www.digitalocean.com/?refcode=4bae360cbe43) VM (most
   of my projects fit into their smallest tier, at least in development). I use their Ubuntu 
   12.04 LTS 64 bit image, and specify my public key as initial auth.
2. From inside my personal fork of basic boxen, I run the exact steps 
   I outlined in the Getting Started section above. My personal fork is unchaged from this one, 
   with the exception of my having customized my credentials as specified above.
3. I then switch over to the app I wish to deploy, set up and configure
   Capistrano as described in the next section, and I'm off to the races.

In most cases, I can go from freshly spun up box to running application in less than 5 minutes, 
without ever having to manually ssh into the server. Nice.

# Deploying apps on a basic boxen

Basic boxen only lays the groundwork for deploying one or more applications to
a server, it doesn't actually deploy an application itself.  Deploying an app is
a task best left to a deployment tool such as [Capistrano](http://capify.org).
Basic boxen enables this by providing a consistent and straightforward
environment that your deployment recipes can rely on in order to focus on the
specific deployment needs of your particular app.

Within the `examples/` directory of this project, you'll find examples of how to
best use Capistrano to deploy several types of applications. It's important to
note that you're able to use any tool you'd like to deploy; Capistrano is only used
an example here. 

## Opinionated deploys

Although you're free to use any tool you'd like to deploy your apps
to a basic boxen, it's best to keep in mind basic boxen's opinionated approach to
responsiblities:

* There are three stages to building a running server:
  * getting a barebones server running (this is your VM provider / hardware team / cloud service's job)
  * *provisioning* a server (this is basic boxen's job)
  * *deploying* apps (this is your deployment tool's job)
* Well defined interfaces between these stages is what makes dev-ops easy. In
  particular, the relationship between provisioning and deployment should be
  modelled on the concept of [policy and
  mechanism](http://en.wikipedia.org/wiki/Separation_of_mechanism_and_policy)
* Anything that exists across applications, or that could reasonably be
  assumed to exist by an app's deployment tool, is a provisioning concern and
  thus within the purview of basic boxen. This includes things such as:
  * Generically configured daemons such as a frontend (ie: nginx) server, and
    a database server
  * Well defined and encapsulated mechanisms for apps to configure specific
    customizations of these daemons
  * A well defined mechanism for apps to daemonize themselves as needed (ie: upstart,
    inittab)
  * A reliable application environment (ie: a current ruby)
  * System level concerns such as ssh access, outgoing mail servers, and time
    servers
* Anything that is specific to a particular app (ie: that would not exist on the
  server were it not for that app) is a deployment concern of that app. This
  includes things such as:
  * The code and data for the app itself
  * Database accounts for the app
  * Frontend server (ie: nginx) configs that are particular to the app
  * Daemonizing any components of the app which require it
  * System-level configuration that is specific to the app (ie: logrotate config
    files)
* Apps should be mindful of the possibility of being run in a multi-tenant
  environment. That is, they should not make assumptions about 'owning' the box
  they're deployed to by doing things like setting the global hostname, taking
  over the global nginx config, etc.

# Growing beyond basic boxen

The whole point of basic boxen is that it lets you lean on sensible defaults and
best practices initially, while allowing you to take the reins and starting
customizing at any time. If (and when) the time comes for you to do this, the
following is a rough guide to making the transition:

1. If you haven't already, fork your own copy of the basicboxen repo, as
   described above.
2. Create customized entries in the `nodes/` directory, naming them after
   specific hostname(s) in your production environment. 

At this point, you will have something resembling a standard Chef repository,
now in a standalone format ready for your tweaking. Any of the various and
plentiful online guides to using Chef can now be applied directly against your
repository. A couple of things to be aware of:

* Since basic boxen is biased towards provisioning a single standalone server,
  it hollows out Postgresql's `pg_hba.conf` file in a way that may be surprising
  to many Postgresql users. See the bottom of basicboxen's
  [postgres](https://github.com/mtrudel/basicboxen/blob/master/roles/postgres.rb)
  role for more information
* Best practices really involve storing variable information in data bags as
  opposed to within a node's config. I've elected to keep things slightly
  non-standard in this regard to make it easier to get up and running with basic
  boxen, but moving more towards data bags is something you'll probably want to
  do (especially if you end up moving to Chef server)

# Super Bonus Extra: Using Vagrant with basic boxen recipes

Included in the basic boxen repo is a basic `Vagrantfile` suitable for use with
the recipes included in basic boxen. The only substantive difference between
Vagrant based builds and knife based builds is that the included `Vagrantfile`
does not include the postgres role by default, and includes libsqlite3 headers
instead. The main reason behind this is to enable easy deployment of rails apps
using a default development `RAILS_ENV`. Changing this is simply a matter of
changing the roles listed in the included `Vagrantfile`

Note that you'll also want to add your account info in the Vagrantfile, as we
did in the `nodes/all_in_one.json` file above. We veer slightly off from
idiomatic Vagrant (if such a thing even exists) by creating our own `deploy` user
to use in place of the default `vagrant` user.

# Super Bonus Extra #2: Capistrano 3 deployment scripts

Included in the `examples/` directory of this project is a set of Capistrano
3 based deployment scripts, including a stage definition that works with the
included `Vagrantfile`.

# Frequently Asked Questions:

* **How do I daemonize apps?** As per the Capistrano recipes discussed in the
  previous section, my preferred way to daemonize apps is to use
  [Foreman](https://github.com/ddollar/foreman)'s mostly excellent upstart
  / inittab export option, and let the system handle daemonizing using its built
  in mechanism (upstart on Ubuntu, inittab on most other distros). This also has
  the upside of transparently supporting any background daemons that are in your
  `Procfile`. Note that the example Capistrano recipes in this project assume an
  upstart (ie: Ubuntu) based server.

# Credits

Credit where credit is due:

* Thanks to [Chef](http://www.opscode.com/chef/) and [knife-solo](http://matschaffer.github.io/knife-solo/) for making this all possible
* Thanks to [Grant McInnes](https://github.com/gmcinnes) and [Crent](https://github.com/bjubinville) for a lot of guidance
  and source material

# Contributing

Contributions welcome! Fork this repo and submit a pull request (or just open up a ticket and I'll see what I can do).
