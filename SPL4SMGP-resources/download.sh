#!/bin/sh

GREP_OPTIONS=''

cookiejar=$(mktemp cookies.XXXXXXXXXX)
netrc=$(mktemp netrc.XXXXXXXXXX)
chmod 0600 "$cookiejar" "$netrc"
function finish {
  rm -rf "$cookiejar" "$netrc"
}

trap finish EXIT
WGETRC="$wgetrc"

prompt_credentials() {
    echo "Enter your Earthdata Login or other provider supplied credentials"
    read -p "Username (imogentlow): " username
    username=${username:-imogentlow}
    read -s -p "Password: " password
    echo "\nmachine urs.earthdata.nasa.gov\tlogin $username\tpassword $password" >> $netrc
    echo
}

exit_with_error() {
    echo
    echo "Unable to Retrieve Data"
    echo
    echo $1
    echo
    echo "https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T223000_Vv3030_001.h5"
    echo
    exit 1
}

prompt_credentials
  detect_app_approval() {
    approved=`curl -s -b "$cookiejar" -c "$cookiejar" -L --max-redirs 2 --netrc-file "$netrc" https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T223000_Vv3030_001.h5 -w %{http_code} | tail  -1`
    if [ "$approved" -ne "302" ]; then
        # User didn't approve the app. Direct users to approve the app in URS
        exit_with_error "Please ensure that you have authorized the remote application by visiting the link below "
    fi
}

setup_auth_curl() {
    # Firstly, check if it require URS authentication
    status=$(curl -s -z "$(date)" -w %{http_code} https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T223000_Vv3030_001.h5 | tail -1)
    if [[ "$status" -ne "200" && "$status" -ne "304" ]]; then
        # URS authentication is required. Now further check if the application/remote service is approved.
        detect_app_approval
    fi
}

setup_auth_wget() {
    # The safest way to auth via curl is netrc. Note: there's no checking or feedback
    # if login is unsuccessful
    touch ~/.netrc
    chmod 0600 ~/.netrc
    credentials=$(grep 'machine urs.earthdata.nasa.gov' ~/.netrc)
    if [ -z "$credentials" ]; then
        cat "$netrc" >> ~/.netrc
    fi
}
    fetch_urls() {
    if command -v curl >/dev/null 2>&1; then
        setup_auth_curl
        while read -r line; do
            curl -f -b "$cookiejar" -c "$cookiejar" -L --netrc-file "$netrc" -Og -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
        done;
    elif command -v wget >/dev/null 2>&1; then
        # We can't use wget to poke provider server to get info whether or not URS was integrated without download at least one of the files.
        echo
        echo "WARNING: Can't find curl, use wget instead."
        echo "WARNING: Script may not correctly identify Earthdata Login integrations."
        echo
        setup_auth_wget
        while read -r line; do
        wget --load-cookies "$cookiejar" --save-cookies "$cookiejar" --keep-session-cookies -- $line && echo || exit_with_error "Command failed with error. Please retrieve the data manually."
        done;
    else
        exit_with_error "Error: Could not find a command-line downloader.  Please install curl or wget"
    fi
}

fetch_urls <<'EDSCEOF'
  https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.18/SMAP_L4_SM_gph_20170918T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.17/SMAP_L4_SM_gph_20170917T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.16/SMAP_L4_SM_gph_20170916T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.15/SMAP_L4_SM_gph_20170915T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.14/SMAP_L4_SM_gph_20170914T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.13/SMAP_L4_SM_gph_20170913T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.12/SMAP_L4_SM_gph_20170912T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.11/SMAP_L4_SM_gph_20170911T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.10/SMAP_L4_SM_gph_20170910T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.09/SMAP_L4_SM_gph_20170909T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.08/SMAP_L4_SM_gph_20170908T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.07/SMAP_L4_SM_gph_20170907T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.06/SMAP_L4_SM_gph_20170906T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.05/SMAP_L4_SM_gph_20170905T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.04/SMAP_L4_SM_gph_20170904T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.03/SMAP_L4_SM_gph_20170903T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.02/SMAP_L4_SM_gph_20170902T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T223000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T193000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T163000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T133000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T103000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T073000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T043000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.09.01/SMAP_L4_SM_gph_20170901T013000_Vv3030_001.h5
https://n5eil01u.ecs.nsidc.org/DP4/SMAP/SPL4SMGP.003/2017.08.31/SMAP_L4_SM_gph_20170831T223000_Vv3030_001.h5

EDSCEOF
