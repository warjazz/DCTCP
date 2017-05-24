#!/bin/bash

bws="100"
#bws="640"
tt="20"
nn="20"
maxq=500

if [ "$UID" != "0" ]; then
    warn "Please run as root"
    exit 0
fi

finish() {
    # Clean up
    killall -9 python iperf
    mn -c

    exit
}

clean_text_files () {
    # Remove random output character in the text file
    dir=${1:-/tmp}
    pushd $dir
    mkdir -p clean
    for f in *.txt; do
        echo "Cleaning $f"
        cat $f | tr -d '\001' > clean/$f
    done
    popd
}

trap finish SIGINT

function tcp {
	bw=$1
	odir=tcp-n$n-bw$bw
	sudo python dctcp.py --bw $bw --maxq $maxq --dir $odir -t $t -n $n
	sudo python ../util/plot_rate.py --maxy $bw -f $odir/txrate.txt -o $odir/rate.png
	sudo python ../util/plot_queue.py --miny 500 -f $odir/qlen_s1-eth1.txt -o $odir/qlen.png
	sudo python ../util/plot_tcpprobe.py -f $odir/tcp_probe.txt -o $odir/cwnd.png
}

function ecn {
	bw=$1
	odir=tcpecn-n$n-bw$bw
	sudo python dctcp.py --bw $bw --maxq $maxq --dir $odir -t $t -n $n --ecn
	sudo python ../util/plot_rate.py --maxy $bw -f $odir/txrate.txt -o $odir/rate.png
	sudo python ../util/plot_queue.py -f $odir/qlen_s1-eth1.txt -o $odir/qlen.png
	sudo python ../util/plot_tcpprobe.py -f $odir/tcp_probe.txt -o $odir/cwnd.png
}

function dctcp {
    bw=$1
    odir=dctcp-n$n-bw$bw
	sudo python dctcp.py --bw $bw --maxq $maxq --dir $odir -t $t -n $n --dctcp
	sudo python ../util/plot_rate.py --maxy $bw -f $odir/txrate.txt -o $odir/rate.png
	sudo python ../util/plot_queue.py --miny 150 -f $odir/qlen_s1-eth1.txt -o $odir/qlen.png
	sudo python ../util/plot_tcpprobe.py -f $odir/tcp_probe.txt -o $odir/cwnd.png
}
for t in $tt; do
for n in $nn; do
for bw in $bws; do
for expt in tcp dctcp; do  # ecn was here, but commented out.
#for expt in tcp; do
    #expt="dctcp"
    
    dir=$expt-n$n-bw$bw-t$t-n$n
    mkdir -p $dir
    touch $dir/qlen_s1-eth1.txt
    touch $dir/txrate.txt
    touch $dir/tcp_probe.txt
    odir=$expt-n$n-bw$bw-t$t-n$n

    # Start the experiment
    if [ "$expt" == "tcp" ]; then 
	sudo python dctcp.py --bw $bw --maxq $maxq --dir $odir -t $t -n $n
#	tcp
    elif [ "$expt" == "ecn" ]; then
	sudo python dctcp.py --bw $bw --maxq $maxq --dir $odir -t $t -n $n --ecn
    elif [ "$expt" == "dctcp" ]; then
	sudo python dctcp.py --bw $bw --maxq $maxq --dir $odir -t $t -n $n --dctcp
#	dctcp
    fi

    # Run plotting scripts
	sudo python ../util/plot_rate.py --maxy $bw -f $odir/txrate.txt -o $odir/rate.png
	sudo python ../util/plot_queue.py --maxy 500 -f $odir/qlen_s1-eth1.txt -o $odir/qlen.png
	sudo python ../util/plot_tcpprobe.py -f $odir/tcp_probe.txt -o $odir/cwnd.png

    #clean_text_files $dir
    wait
done
done
done
done

finish


