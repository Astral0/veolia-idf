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


# Check for ghost sessions
is_xvfb=$(ps -ef | grep 'Xvfb :99' | grep -v grep | awk '{print $2}')
if [ ! -z "${is_xvfb}" ]; then
    ps -ef | grep 'Xvfb :99' | grep -v grep | awk '{print $2}' | xargs -r kill -9
fi


# Run
cd $root/
xvfb-run timeout --signal=SIGINT ${timeout} python3 $root/veolia-idf-domoticz.py -d --run $*
codret=$?

# Kill ghosts processes
nbprocess=$(pgrep -u www-data -f "python3 $root/veolia-idf-domoticz.py" -c)
if [ ! $nbprocess -eq 0 ]; then
    pkill -u www-data -f "python3 $root/veolia-idf-domoticz.py"
fi

exit ${codret}


