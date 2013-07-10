# Basic boxen

I wrote basic boxen to give me a consistent baseline environment to deploy apps
(mostly rails apps) to, one that was consistent across all my projects, yet
flexible enough to handle whatever I could throw at it. Basic boxen does just
that -- it's an opinionated set of chef cookbooks and default configs that gives
you a great development environment, while laying the groundwork for
sustainable growth into production. Using basic boxen in tandem with my
capistrano-basicboxen gem (to be released in the next couple of days) provides
a wonderful and simple way to deploy and run a standard Procfile based app with
minimal hassle.

# Getting started (in a broad sense)

## Adding in your info

To install a box with basic boxen, clone this repo to your local machine, and
make sure you have all the local gems and cookbooks installed on your local
machine:

    git clone git@github.com:mtrudel/basicboxen.git
    cd basicboxen
    bundle install
    bundle exec berks install

Next, you'll want to edit (and probably commit) the `nodes/all_in_one.json` file
and make the following changes:

* Change the address that root's email is forwarded to on line 11
* Add your ssh public key (ie: the contents of your `~/.ssh/id_[dr]sa.pub` file)
  into the `ssh_keys` array on line 18

That's it! You're now ready to start making servers!

## Making a box

Now that you've made basic boxen your own, you can build any number of boxes from this 
recipe by running:

    bundle exec knife solo bootstrap root@host nodes/all_in_one.json

Note that you only run as the remote root user the first time you run on the
remote server. Since the initial run of chef will create a deploy user, set them up
with passwordless sudo, and revoke root login via ssh, subsequent runs thus must
be done like:

    bundle exec knife solo bootstrap deploy@host nodes/all_in_one.json

Unless you're making changes to your basic boxen fork, you shouldn't ever need
to run your configuration more than once (though it's totally safe to)

# What this gets you

When this build completes, you'll have a machine running with the following:

* A running nginx instance with no hosts defined (and thus not bound anywhere)
* A domain socket only postgres server running, with 'peer' authentication
* Ruby 1.9.3 running inside rbenv, with the bundler gem installed
* A user 'deploy' with passwordless sudo and public-key only auth using your
  public key
* A postfix server running on localhost, with admin mail forwarded to your email
  address
* Basic admin stuff like logrotate, ntp, unattended upgrades all running

This basic deployment has only SSH and NTP open to the world, and has a very
small attack surface exposed on SSH (all access is public key only, and root
login is disabled). Everything from here onwards is considered to be
a deployment concern, and can be well handled within your deployment tool of
choice (I would suggest my **capistrano-basicboxen** gem to do this, as it's
designed specifically to deploy generic Procfile apps to basic boxen boxes).

# What does this *not* get you (yet)

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

# Basic Boxen's Opinions

TBD

# Credits

Credit where credit is due:

* Thanks to [Chef](http://www.opscode.com/chef/) and [knife-solo](http://matschaffer.github.io/knife-solo/) for making this all possible
* Thanks to [Grant McInnes](https://github.com/gmcinnes) for a lot of guidance
  and source material

# Contributing

Contributions welcome! Fork this repo and submit a pull request (or just open up a ticket and I'll see what I can do).
