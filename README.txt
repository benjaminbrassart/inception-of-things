hello

Subject:
https://cdn.intra.42.fr/pdf/pdf/68742/en.subject.pdf

Videos:
https://www.youtube.com/watch?v=czMCO1w-xQU&list=PLhW3qG5bs-L9S272lwi9encQOL9nMOnRa&index=1
https://www.youtube.com/watch?v=Vcs_9U88EzI&list=PLn6POgpklwWqU5IQGKZXladpC8OWabyKI&index=1
https://www.youtube.com/watch?v=5-PGV-r_684
https://www.youtube.com/watch?v=80Ew_fsV4rM
https://www.youtube.com/watch?v=T4Z7visMM4E

Errors:
```
There was an error while executing `VBoxManage`, a CLI used by Vagrant
for controlling VirtualBox. The command and stderr is shown below.

Command: ["import", "/mnt/nfs/homes/bbrassar/.vagrant.d/boxes/debian-VAGRANTSLASH-buster64/10.20230615.1/virtualbox/box.ovf", "--vsys", "0", "--vmname", "box_1696841377216_42862", "--vsys", "0", "--unit", "9", "--disk", "/mnt/nfs/homes/bbrassar/VirtualBox VMs/box_1696841377216_42862/box.vmdk"]
```

-> EDQUOT - Disk quota exceeded

```
The guest machine entered an invalid state while waiting for it
to boot. Valid states are 'starting, running'. The machine is in the
'poweroff' state. Please verify everything is configured
properly and try again.

If the provider you're using has a GUI that comes with it,
it is often helpful to open that and watch the machine, since the
GUI often has more helpful error messages than Vagrant can retrieve.
For example, if you're using VirtualBox, run `vagrant up` while the
VirtualBox GUI is open.

The primary issue for this error is that the provider you're using
is not properly configured. This is very rarely a Vagrant issue.
```

-> For some reason, VirtualBox 6.1.44 + vagrant 2.3.0 works and other combinations may not.
https://discuss.hashicorp.com/t/virtualbox-ignores-command-line-from-vagrant/53156/2
