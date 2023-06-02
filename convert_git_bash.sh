#!/usr/bin/env bash

MSYS_DOWNLOAD_URL="https://repo.msys2.org/distrib/msys2-x86_64-latest.tar.xz"
MSYS_FILENAME="$(basename "$MSYS_DOWNLOAD_URL")"

CHECK_ADMIN="${CHECK_ADMIN:-yes}"

CONFIRM_BEFORE_PROCEEDING="${CONFIRM_BEFORE_PROCEEDING:-yes}"

# Each of these can be yes, no, or check.
DOWNLOAD_MSYS=${DOWNLOAD_MSYS:-check}
UNTAR="${UNTAR:-check}"
UPDATE_GPG="${UPDATE_GPG:-check}"
FIX_BROKEN_PACKAGES="${FIX_BROKEN_PACKAGES:-check}"
UPDATE_MSYS2="${UPDATE_MSYS2:-check}"

. ./convert_git_bash_functions

if [[ $CHECK_ADMIN == "yes" ]] && ! isadmin; then
    echo "Run this as administrator or unset CHECK_ADMIN in the script if you know what you're doing!"
    exit 1
fi

if [[ $DOWNLOAD_MSYS == "check" ]]; then
    echo -n "Checking if we need to download msys2..."
    if [[ -f $MSYS_FILENAME ]]; then
        DOWNLOAD_MSYS=no
    else
        DOWNLOAD_MSYS=yes
    fi
    echo "$DOWNLOAD_MSYS"
fi

if [[ $UNTAR == "check" ]]; then
    echo -n "Checking if we need to untar msys2..."
    if [ -f /usr/bin/pacman.exe ]; then
        UNTAR=no
    else
        UNTAR=yes
    fi
    echo "$UNTAR"
fi

if [[ $UPDATE_GPG == "check" ]]; then
    echo -n "Checking if we need to update GPG keys..."
    if [ -d /etc/pacman.d/gnupg ]; then
        UPDATE_GPG=no
    else
        UPDATE_GPG=yes
    fi
    echo "$UPDATE_GPG"
fi

if [[ $UPDATE_MSYS2 == "check" ]]; then
    echo -n "Checking if we need to update msys2-runtime..."
    if ! pacman -Qu 2>/dev/null | grep -q "msys2-runtime"; then
        UPDATE_MSYS2=no
    else
        UPDATE_MSYS2=yes
    fi
    echo "$UPDATE_MSYS2"
fi

if [[ $FIX_BROKEN_PACKAGES == "check" ]]; then
    echo -n "Checking if we need to fix broken packages..."
    if [ -z "$(find_broken_packages)" ]; then
        FIX_BROKEN_PACKAGES=no
    else
        FIX_BROKEN_PACKAGES=yes
    fi
    echo "$FIX_BROKEN_PACKAGES"
fi

if [[ $CONFIRM_BEFORE_PROCEEDING == "yes" ]]; then
    read -p "Do you wish to proceed? (y/n) " response
    if [[ $response != "y" ]]; then
        echo "User responded $response.  Exiting."
        exit 0
    else
        echo "Proceeding based on user response of $response."
    fi
fi

if [[ $DOWNLOAD_MSYS == "yes" ]]; then
    echo "Downloading $MSYS_FILENAME from $MSYS_DOWNLOAD_URL"

    curl "$MSYS_DOWNLOAD_URL" -o "/tmp/$MSYS_FILENAME" &&
    mv "/tmp/$MSYS_FILENAME" "$MSYS_FILENAME"
fi

if [[ $UNTAR == "yes" ]]; then
    tar xvf "$MSYS_FILENAME" --strip-components=1 -C / \
        msys64/usr/bin/pacman.exe \
        msys64/usr/bin/pacman-key \
        msys64/usr/bin/pacman-conf.exe \
        msys64/usr/bin/pacman-db-upgrade \
        msys64/etc/pacman.conf \
        msys64/etc/pacman.d \
        msys64/var/lib/pacman \
        msys64/usr/share/makepkg/executable/pacman.sh \
        msys64/etc/makepkg.conf \
        msys64/etc/makepkg_mingw.conf \
        msys64/usr/bin/makepkg \
        msys64/usr/bin/makepkg-mingw \
        msys64/usr/bin/makepkg-template \
        msys64/usr/share/makepkg \
        msys64/usr/share/pacman \
        msys64/etc/post-install

    if [ ! $? ]; then
        echo "tarball extraction failed.  It is recommended to correct prior to proceeding."
        exit 1
    fi
fi

if [[ $UPDATE_GPG == "yes" ]]; then
    echo "Re-initializing GPG keys."

    if [ -d /etc/pacman.d/gnupg ]; then
        rm -rf /etc/pacman.d/gnupg
    fi

    . /etc/post-install/07-pacman-key.post

    if [ ! $? ]; then
        echo "GPG post-install script failed.  It is recommended to correct prior to proceeding."
        exit 1
    fi
fi

if [[ $UPDATE_MSYS2 == "yes" ]]; then
    echo "This will require you to restart git bash (probably as admin).  Ensure you wish to proceed before continuing!"
    echo ""
    echo "Re-run this script when you restart git bash afterward!"
    pacman -Syu msys2-runtime
    # Ensure we exit instead of moving on in case the process goes over or the
    # strange universe that allows msys2-runtime to update assemblies in-place.
    exit 0
fi

if [[ $FIX_BROKEN_PACKAGES == "yes" ]]; then
    echo "Fixing broken packages."
    broken_packages=$(find_broken_packages)
    if [[ -n $broken_packages ]]; then
        pacman -S $broken_packages --overwrite "*" --noconfirm
    else
        echo "No broken packages found."
    fi
    broken_packages=$(find_broken_packages)
    if [[ -n "$broken_packages" ]]; then
        echo "The following packages are still broken:"
        for package in $broken_packages; do
            echo "    $package"
        done
    else
        echo "All packages seem well according to pacman!"
    fi
fi
