#!/bin/bash

# Timeout in secondes
timeout=600

# Get current directory
set_root() {
    local this=`readlink -n -f $1`
    bin=`dirname $this`
    root=`dirname $bin`
}
set_root $0

export PYTHONPATH=${root}/lib/

cd $root/
xvfb-run timeout --signal=SIGINT ${timeout} python3 $root/veolia-idf-domoticz.py -d --run $*
codret=$?

# Kill ghosts processes
nbprocess=$(pgrep -u www-data -f "python3 $root/veolia-idf-domoticz.py" -c)
if [ ! $nbprocess -eq 0 ]; then
    pkill -u www-data -f "python3 $root/veolia-idf-domoticz.py"
fi

exit ${codret}


