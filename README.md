# inception-of-things

By bbrassar and jfremond

## Part 3

Part 3 has several scripts:
* `init.sh` installs necessary tools, should be used once per machine
* `deinit.sh` reverts what `init.sh` does
* `setup.sh` sets the actual project up
* `cleanup.sh` reverts what `setup.sh` does
* `run-port-forward.sh` exposes a port that redirects to Argo CD UI
