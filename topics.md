Topics
======

## Performance Tuning
chrt
cpu governor
disable irq balance
```bash
# Set the kernel to use low-latency parameters
vm.swappiness = 10
kernel.sched_latency_ns = 10000000
kernel.sched_min_granularity_ns = 1000000
kernel.sched_wakeup_granularity_ns = 5000000
```
nice
renice
cpupower
taskset
cset
isolcpus
nohz_full
rcu_nocbs
/proc/interrupts
mask irq affinity
isolcpus / nohz_full → keep critical cores free from noise
✅ cgroups v2 cpuset → pin apps to those cores
✅ cgroups v2 cpu.max → control bandwidth
✅ cgroups v2 memory.min → protect memory
✅ irq affinity → keep interrupts off isolated cores
