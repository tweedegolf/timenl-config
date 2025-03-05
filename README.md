# Combined Statime + ntpd-rs setup
This is a combined Statime and ntpd-rs setup that contains a statime instance
running in slave-only and an ntpd-rs instance configured as a local-clock
stratum 1 server without any other remote sources, meaning it will follow
whatever the Statime PTP daemon is doing.

This setup allows a (local) PTP to accurately condition the system clock to very
closely follow a PTP network, and then exposing that time through ntpd-rs to a
wider network.

## How is this set up?
This setup is created using an ansible playbook containing two ansible roles,
one for setting up statime, and one for setting up ntpd-rs. For more information
about ansible roles and playbooks, please see the [ansible documentation]. For
running the ansible playbook a python3 installation is required.

This setup was tested on a set of Ubuntu 24.04 instances, but should work with
similar systems as well. A Debian derivative using apt and systemd with a
somewhat recent libc is required however. No particularly modern Linux kernel
features are used by either statime or ntpd-rs. Specially compiled linux
kernels (i.e. a low latency kernel) or OS tunings should be unnecessary, and a
normal setup should already work very well.

The system running these services should generally not run any other programs
that result in a heavy system load, as time synchronization performance reduces
with a more heavily used system. If the system is expected to run under heavy
NTP load it might help to increase the priority of the statime process to ensure
proper system clock synchronization. Increasing the priority of the ntpd-rs
process might help a little bit in sending the most accurate results, but it
would be better to balance the load accross multiple NTP instances instead.

[ansible documentation]: https://docs.ansible.com/

## Deploying
To setup a deployment, start by configuring an inventory file for which machines
are to be provisioned. An example inventory is shown in `inventory.yaml`. This
example also explains each of the variables that can be configured. Note that
variables can be set either globally or per host.

To deploy, simply run `ansible-playbook -i [my inventory] playbook.yaml`.

## Metrics
Both ntpd-rs and statime have their metrics exporters started up in this setup.
These exporters export metrics using prometheus. You can configure the address
on which the metrics listen. From that point, you should configure your own
prometheus instance to read metrics from those endpoints.
