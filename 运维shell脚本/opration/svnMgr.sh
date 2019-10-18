#!/bin/bash

#$1 cmd(only accept add|status|reset|diff|commit)
#$2 params

cd `dirname $0`;

cd ../../
#cd ../gitTest

case $1 in
add)
    svn add "$2"
   ;;
status)
    svn status --porcelain
   ;;
reset)
    git reset HEAD "$2"
   ;;
diff)
    git diff "$2"
   ;;
commit)
    git commit -m "msg:$2"
   ;;
pull)
    git pull
   ;;
push)
    git push --porcelain
   ;;

esac


