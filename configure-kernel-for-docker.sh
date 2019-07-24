#!/usr/bin/env bash
# This script enables required Linux kernel configs for Docker.
# Should be run from the kernel source directory.

KERNEL_CONFIGS="

# List from docker ebuild

CONFIG_CGROUP_DEVICE
CONFIG_MEMCG
CONFIG_VETH
CONFIG_BRIDGE
CONFIG_BRIDGE_NETFILTER
CONFIG_NF_NAT_IPV
CONFIG_IP_NF_TARGET_MASQUERADE
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE
CONFIG_NETFILTER_XT_MATCH_IPVS
CONFIG_IP_NF_NAT
CONFIG_NF_NAT
CONFIG_NF_NAT_NEEDED
CONFIG_USER_NS
CONFIG_CGROUP_PIDS
CONFIG_MEMCG_SWAP
CONFIG_MEMCG_SWAP_ENABLED
CONFIG_BLK_CGROUP
CONFIG_BLK_DEV_THROTTLING
CONFIG_CFQ_GROUP_IOSCHED
CONFIG_CGROUP_PERF
CONFIG_CGROUP_HUGETLB
CONFIG_NET_CLS_CGROUP
CONFIG_CFS_BANDWIDTH
CONFIG_RT_GROUP_SCHED
CONFIG_IP_VS
CONFIG_IP_VS_PROTO_TCP
CONFIG_IP_VS_PROTO_UDP
CONFIG_IP_VS_NFCT
CONFIG_IP_VS_RR
CONFIG_VXLAN
CONFIG_IPVLAN
CONFIG_MACVLAN
CONFIG_DUMMY
CONFIG_CGROUP_NET_PRIO
CONFIG_OVERLAY_FS

# Additional configs these above depend on

CONFIG_INET
CONFIG_NET
CONFIG_NETFILTER
CONFIG_NETFILTER_ADVANCED
CONFIG_NF_CONNTRACK
CONFIG_SWAP

"

old_notfound=0
while true; do
	notfound=0
	notfound_list=""
	for kconfig in $KERNEL_CONFIGS; do
		if [[ ${kconfig} == CONFIG* ]]; then
			if grep -qsE "$kconfig(=| is not set)" .config; then
				sed -i -E "s/(# )?$kconfig(=.| is not set)/$kconfig=y/" .config 
			else
				notfound_list="$notfound_list $kconfig"
				((notfound++))
			fi
		fi
	done
	if [ "$notfound" == "0" ]; then
		exit
	fi
	if [ "$notfound" == "$old_notfound" ]; then
		echo "Following configs could not be set: $notfound_list"
		exit
	else
		make olddefconfig
	fi
	old_notfound=$notfound
done
