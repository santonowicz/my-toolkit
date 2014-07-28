#!/bin/bash

## CONFIG ##
clean=0 # Clean up?
bstrap="src/bootstrap.php" # PHPUnit Bootstrap File
tdir="tests" # PHPUnit tests directory
## /CONFIG ##

key_exists=`gpg --list-keys | grep "6372C20A 2014-07-19"| wc -l`
if [ "$key_exists" -eq 0 ]; then
    echo -e "\033[33mDownloading PGP Public Key...\033[0m"
    gpg --recv-keys 0x4AA394086372C20A
    # Sebastian Bergmann 
fi

if [ "$clean" -eq 1 ]; then
    # Let's clean them up, if they exist
    if [ -f phpunit.phar ]; then
        rm -f phpunit.phar
    fi
    if [ -f phpunit.phar.asc ]; then
        rm -f phpunit.phar.asc
    fi
fi

# Let's grab the latest release and its signature
if [ ! -f phpunit.phar ]; then
    wget https://phar.phpunit.de/phpunit.phar
fi
if [ ! -f phpunit.phar.asc ]; then
    wget https://phar.phpunit.de/phpunit.phar.asc
fi

# Verify before running
gpg --verify phpunit.phar.asc phpunit.phar
echo
if [ $? -eq 0 ]; then
    echo -e "\033[33mBegin Unit Testing\033[0m"
    # Run the testing suite
    php phpunit.phar --bootstrap $bstrap $tdir
    # Cleanup
    if [ "$clean" -eq 1 ]; then
        echo -e "\033[32mCleaning Up!\033[0m"
        rm -f phpunit.phar
        rm -f phpunit.phar.asc
    fi
else
    chmod -x phpunit.phar
    mv phpunit.phar /tmp/bad-phpunit.phar
    echo -e "\033[31mSignature did not match! Check /tmp/bad-phpunit.phar for trojans\033[0m"
    exit 1
fi