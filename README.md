Mob Rotation
============

### Features
* Command line interface to simulate the [mob programming][mob_wiki_link] environment
* Timer funtionality to indicate rotation
* Ability to tell who is the driver, navigator and mobsters

### Instructions For Use
Organizing a group and getting everyone logged in to a single machine is hard enough: let the **mob_rotation** tool handle the rest!

First, install the mob_rotation gem from the terminal:

`$ gem install mob_rotation`

Now that the gem is installed, get a handy list of commands by running:

`$ mob_rotation help`

Nice! But mob programming revolves around action, so let's get our team in place using the `add` command:

`$ mob_rotation add "John Lennon <john@thebeatles.com>"`

Sweet! John has been added. Suppose you wanted to `add` the rest of the mobbers in one line:

`$ mob_rotation add "Paul McCartney <paul@thebeatles.com>" "George Harrison <george@thebeatles.com>" "Ringo Starr <tingo@thebeatles.com>"`

Boom! Let's make sure they were all added correctly with the `show` command:

`$ mob_rotation show`

Here's what we get back:

```
git username: John Lennon
git user email: john@thebeatles.com
Driver John Lennon <john@thebeatles.com>
Navigator Paul McCartney <paul@thebeatles.com>
Mobster George Harrison <george@thebeatles.com>
Mobster Ringo Starr <tingo@thebeatles.com>
```

Shoot! We have a typo in Ringo's email address, so let's `remove` him then `add` him back with the correct info:

```
$ mob_rotation remove "Ringo Starr"
$ mob_rotation add "Ringo Starr <ringo@thebeatles.com>"
```

Alright, we think we got it right this time... Let's use `show` to verify:

`$ mob_rotation show`

Which returns:

```
git username: John Lennon
git user email: john@thebeatles.com
Driver John Lennon <john@thebeatles.com>
Navigator Paul McCartney <paul@thebeatles.com>
Mobster George Harrison <george@thebeatles.com>
Mobster Ringo Starr <ringo@thebeatles.com>
```

Perfect! Before we start hacking away, let's randomize our participant order with `random`:

`$ mob_rotation random`

Which returns:

```
git username: Ringo Starr
git user email: ringo@thebeatles.com
Driver Ringo Starr <ringo@thebeatles.com>
Navigator George Harrison <george@thebeatles.com>
Mobster John Lennon <john@thebeatles.com>
Mobster Paul McCartney <paul@thebeatles.com>
```

Awesome! The group has been shuffled up and new roles have been assigned. Ringo is ready to drive, and George is ready to navigate: we'll start a 5-minute (300 second) mob cycle using the `run_with_timer` command:

`$ mob_rotation run_with_timer 300`

Great! George navigates and Ringo drives for 5 minutes, and as soon as that time is up the tool sends us a message at the command line:

`Time to rotate`

Solid! Let's move forward one cycle by using the `rotate` command:

`$ mob_rotation rotate`

Which returns:

```
git username: George Harrison
git user email: george@thebeatles.com
Driver George Harrison <george@thebeatles.com>
Navigator John Lennon <john@thebeatles.com>
Mobster Paul McCartney <paul@thebeatles.com>
Mobster Ringo Starr <ringo@thebeatles.com>
```

Repeat the `run_with_timer` and `rotate` commands until the end of the mob session!

### Gems and Dependencies
* Ruby 2.1.2
* RSpec

### Upcoming Features
* Timer
* Randomization of Driver/Navigator
* Browser-based GUI

### Additional Resources
* <http://mobprogramming.org/>

### Credits
TODO

[mob_wiki_link]: http://en.wikipedia.org/wiki/Mob_programming
