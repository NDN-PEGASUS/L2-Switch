#!/bin/bash
CURPATH=$(cd `dirname $0`; pwd)

[ -z ${SDE} ] && echo "Environment variable SDE not set" && exit 1
[ -z ${SDE_INSTALL} ] && echo "Environment variable SDE_INSTALL not set" && exit 1
export SDE=${SDE}
export SDE_INSTALL=${SDE_INSTALL}

cd $SDE
bf_kdrv_mod=`lsmod | grep bf_kdrv`
if [ -z ${bf_kdrv_mod} ]; then
    echo "loading bf_kdrv_mod..."
    bf_kdrv_mod_load $SDE_INSTALL
fi

./run_switchd.sh -p l2switch --arch tf2
cd $CURPATH