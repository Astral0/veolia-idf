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



find_free_servernum() {
    i=0
    while [ -f /tmp/.X$i-lock ]; do
        i=$(($i + 1))
    done
    echo $i
}

x_num=$(find_free_servernum)


# Run
cd $root/
#xvfb-run timeout --signal=SIGINT ${timeout} python3 $root/veolia-idf-domoticz.py -d --run $*
Xvfb :${x_num} -screen 0, 1024x768x16 &
export DISPLAY=:${x_num}
timeout --signal=SIGINT ${timeout} python3 $root/veolia-idf-domoticz.py --mqtt --debug --run $*
codret=$?


# Kill ghosts processes
nbprocess=$(pgrep -u www-data -f "python3 $root/veolia-idf-domoticz.py" -c)
if [ ! $nbprocess -eq 0 ]; then
    pkill -u www-data -f "python3 $root/veolia-idf-domoticz.py"
fi


# Check for ghost sessions
is_xvfb=$(ps -ef | grep "Xvfb :$x_num" | grep -v grep | awk '{print $2}')
if [ ! -z "${is_xvfb}" ]; then
    ps -ef | grep "Xvfb :$x_num" | grep -v grep | awk '{print $2}' | xargs -r kill -9
    rm -rf /tmp/.X${x_num}-lock
fi

exit ${codret}
