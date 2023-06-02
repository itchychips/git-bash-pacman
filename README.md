# git-bash-pacman

The script `convert_git_bash.sh` and its supporting file
`convert_git_bash_functions` attempt to convert your git bash installation
without `pacman` into an installation that has `pacman` so you can install
packages.

# Warning

This is very much unsupported by anyone upstream, and a pretty ridiculous thing
to do.  Also, this works for my usecase.

It is highly recommended to have a usecase which does *not* use UNC paths in
any capacity (such as `git bash` being on a remote directory or executing the
scripts from the same), such as `\\?\C:\example\path\here` or
`\\my_host\example\path\here`.  Not only will network paths likely be slow (as
in the latter case), it is untested whether or not it will even work.

Your mileage will vary, and I don't have any fuel for you.

# Usage

This has been tested against the 64-bit version of Git for Windows as installed
by its standalone installer for system-wide use.

Retrieve the `convert_git_bash.sh` and `convert_git_bash_functions` files, put
them somewhere that git bash has access to (your home directory is good
enough).

Then, run the git bash terminal as admin.  This is required for system-wide
installs, unless your user has read/write access to all paths underneath the
msys root for git.  If you have a user installation of Git for Windows, this
might work without admin, but has not been tested.

The following environment variables modify execution, with the following defaults:

    
    CHECK_ADMIN=yes
    CONFIRM_BEFORE_PROCEEDING=yes

    DOWNLOAD_MSYS=check
    UNTAR=check
    UPDATE_GPG=check
    FIX_BROKEN_PACKAGES=check
    UPDATE_MSYS2=check

These environment variables also are in the same order as the general steps, so
these can be modified for troubleshooting purposes.

# Discussion

This is a ridiculous way to work around downloading the msys2 installer or
grabbing the [Git for Windows
SDK](https://github.com/git-for-windows/build-extra/releases/tag/git-sdk-1.0.8)
to get a more fully-featured shell environment.

However, some things to note:

1. You probably already have a Git for Windows installation if you use git on
   Windows.
2. You can reuse the installation instead of setting everything up again.
3. You can shed tears whenever it automatically updates, because that will
   probably break something.

In the grand scheme of the Machine God, it's probably okay for if you only need
a couple of packages.

Obviously, I don't recommend relying on this for any critical usecases, such as
making sure your pacemaker software builds or your pizza gets delivered on
time.  In other usecases, it's likely decent if you have the motivation to fix
random happenstances that come your way.

As an aside, we do just grab the msys2 distribution tarball from upstream, and
it extracts with the default msys2-git distribution.  You could just use that.

I wanted to retrieve the specific packages I needed, like pacman and its
supporting packages, but I couldn't find anything to extract this newfangled
`.zst` file type so I could just grab the exact packages I needed (not even
7zip, which extracts everything, so I am led to believe `.zst` is just
something that doesn't exist), so you could just use that, but that'd be less
complicated.  That would have been far more hacky, so it's probably better that
didn't work.

# License

See COPYING.txt.  It's AGPL (v3!).  If you can figure out a way to do network
interaction with this program such that you're required to distribute your
modifications and show me, I'll be impressed and may or may not send you 10
USD.
