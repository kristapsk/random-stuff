#! /bin/sh

if [[ "$1" == "" ]]; then
        echo "Usage: `basename $0` dev"
        echo "Example: `basename $0` sdc"
        exit 1
fi

dev="$1"

if [ ! -d "/sys/block/$dev/queue" ]; then
        echo "Invalid device, /sys/block/$dev/queue directory does not exist!"
        exit 1
fi

is_power_of_two() {
        x=$1
        while [[ "$(( $x % 2 ))" == "0" && $(( $x > 1 )) ]]  ; do
                x=$(( $x / 2 ))
        done
        if [[ "$x" == "1" ]]; then
                echo 1
        else
                echo 0
        fi
}

optimal_io_size="`cat /sys/block/$dev/queue/optimal_io_size`"
minimum_io_size="`cat /sys/block/$dev/queue/minimum_io_size`"
alignment_offset="`cat /sys/block/$dev/alignment_offset`"
logical_block_size="`cat /sys/block/$dev/queue/logical_block_size`"

# From http://h10025.www1.hp.com/ewfrf/wc/document?cc=uk&lc=en&dlc=en&docname=c03479326
# 1. Always use the reported alignment offset as offset.
# 2. a. If optimal io size is present in the topology info, use that as grain.
# 2. b. If optimal io size is not present in topology info and alignment offset is 0 and minimum io size is a power of 2, use the default optimal alignment (grain 1MiB).
# 2. c. If not 2a and 2b, use the minimum io size, or if that is not defined the physical sector size as grain (iow the minimum alignment).
if [[ "$optimal_io_size" != "0" ]]; then
        echo $(( ( $alignment_offset + $optimal_io_size ) / $logical_block_size ))s
else
        if [[ "$alignment_offset" == "0" && "$(is_power_of_two $minimum_io_size)" == "1" ]]; then
                echo $(( 1048576 / $logical_block_size ))s
        else
                echo $(( ( $alignment_offset + $minimum_io_size ) / $logical_block_size ))s
        fi
fi

