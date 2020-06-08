#!/bin/bash
# exit when any command fails
set -e
echo 'ensures current branch is master'
echo 'git checkout master'
git checkout master
echo 'pulls all new commits made to upstream/master'
echo 'git pull upstream master'
git pull upstream master
echo 'this will delete all your local changes to master'
echo 'git reset --hard upstream/master'
git reset --hard upstream/master
echo ' take care, this will delete all your changes on your forked master'
echo 'git push origin master --force'
git push origin master --force
