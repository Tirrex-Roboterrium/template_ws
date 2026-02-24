## Using local tirrex_workspace

This approach is not recommended, but if you want to use a local copy of tirrex_workspace instead of
the one that is included in the docker image, you can follow these instructions.

You first need to install tirrex_workspace by following instructions in the
[README of this workspace](https://github.com/Tirrex-Roboterrium/tirrex_workspace).
If you are an INRAE developer, you have to follow the specific instructions (there is a section
after installation) and use the repository from the INRAE forge.
This workspace must be installed outside of this project.

After that, you have to define an environment variable `TIRREX_WORKSPACE` that contains the path of
the tirrex workspace you just have installed
```bash
echo >>.env TIRREX_WORKSPACE="<path/to/tirrex/workspace>"
```

Now, you can create a `compose.override.yaml` file to change some parameters of the default
`compose.yaml`.
For example, to override the `compile` service, the file will look like this:
```yaml
services:
  compile:
    volumes:
      - ${TIRREX_WORKSPACE}:${TIRREX_WORKSPACE}:ro
    environment:
      - TIRREX_WORKSPACE=${TIRREX_WORKSPACE}
```
This file is automatically read by `docker compose`, so the commands do not change.
If you want to apply that to all services, it is also possible to directly edit
`docker/common.yaml`.
In any case, make sure to not commit your changes, unless you want them to apply to everyone.
