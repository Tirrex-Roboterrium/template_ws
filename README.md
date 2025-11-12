This project is a ROS2 workspace that extends the tirrex_workspace.
Its aim is to provide a simple way to work with tirrex and TSCF developments without having to
recompile everytime the packages of the tirrex workspace (there are more than 150 of them).
To do that, it exploits the concept of
[underlay and overlay](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html#source-the-overlay)
defined by ROS.
In this case, we use the following workspaces:
* /opt/ros/humble (underlay)
* tirrex_workspace (underlay)
* this workspace (overlay)

It significates that if you want to modify a package that is defined in tirrex_workspace, instead of
modifying it in tirrex_workspace, you have to clone this package into your workspace and make your
changes locally.
This allows keeping a clean tirrex_workspace and simplify its update.

# Installation

This project is just a template to create your own workspace.
Instead of cloning the repository using the "code" button of the web interface, you will create your
own version by clicking the "fork" button.
This action open a new page to specify the name and the namespace of the workspace.
Choose a name that best describes what you want to do (example: a short title of your PhD thesis or
the name of your research project) and select the correct namespace of your research group.
If you don't know it, ask your supervisors.

You first need to download it using `git clone`.
Replace the `<elements>` by the correct values
```bash
git clone git@<URL_of_your_group>/<name_of_your_project>.git
```
If you receive an error message specifying you don't have permission to use ssh with the server, you
can follow theses instructions:
[Cloning by SSH](https://forge.inrae.fr/tscf/knowledge/-/blob/main/git/git_clone_project.md?ref_type=heads#cloning-by-ssh).

From the root of the workspace, execute the script `create_ws` to create a `.env` that contains
some environment variables useful to build the docker images, and also clone demos examples.
```bash
cd <name_of_your_project>
./scripts/create_ws
```

This script will try to find the directory `tirrex_workspace` or `tirrex_ws` at the same level of
this one.
If this workspace is detected, you can choose to use this one instead of the embedded one, but it is
not recommended.

Now you can compile the workspace
```bash
docker compose run --rm compile
```

The first time, this command will create a docker image with the name of your workspace.
This image is based on the one of tirrex_workspace.
Regarding the compilation, it will do nothing because you don't have any packages at the moment.
You can now create your own ROS package in `src` directory and start working!

You can open a shell inside the ROS environment using
```bash
docker compose run --rm bash
```
This command starts an interactive docker container in your workspace.
Everything is already sourced, so you can execute any `ros2 run` or `ros2 launch` with a package of
your workspace or tirrex_workspace.
However, it is better to [use a demo](#launching-a-demo) rather than starting launch manually.


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


# Launching a demo

The `demo` folder contains a set of examples to start various simulations or real-world experiments.
Unlike typical use of ROS tools, it's not necessary to manually run the `ros launch` commands.
Each demo folder contains a `compose.yaml` file that allows you to automatically launch ROS in
containerized environments.
To launch a demo, simply navigate to the demo folder and run:
```
docker compose up
```
This command will then start all the (non-optional) services defined in the `compose.yaml` file.
Each service corresponds to a specific ROS command.

For example, to start the demo `simu_workshop`, you have to do the following commands from the root
of the workspace:
```bash
cd demos/example/simu_workshop
docker compose up
```

## Better use of docker compose commands

If you use the `docker compose up` command in a terminal, the terminal will be blocked while the
demo is running.
If you want to continue using the terminal, you can start the demo in the background with the `-d`
option (to detach).
```bash
docker compose up -d [<service_name>] ...
```
By default, it starts all the non-optional services defined in the `compose.yaml` file, but you can
start services individually by specifying their name in the command line.
For optional services, specifying their name is required.

The `bash` service is a special case because it needs to be interactive to run commands.
You must use the `run` subcommand instead of `up`.
And to avoid keeping unnecessary containers, you should add the `--rm` option.
```bash
docker compose run --rm bash
```

You can view the currently running services at any time with the command:
```bash
docker compose ps
```

If you want to check the outputs of one of the services, you can use:
```bash
docker compose logs -f [<service_name>] ...
```
The `-f` option allows to follow the new messages in real-time.
It is possible to combine the outputs of several services by specifying several names.
If you do not specify any names, it will show all the logs at the same time.

To stop one or several services, the command is:
```bash
docker compose stop [<service_name>] ...
```
If you do not specfy any names, it will stop all the non-optional services.

To stop all the services (optional or not), the command is:
```bash
docker compose --profile '*' stop
```

To list all the available `docker compose` commands, you can run it without sub-commands:
```bash
docker compose
```


# Create your own demos

The demos in the `demos/examples` directory should not be modified.
This folder is a shared git subproject across all workspaces based on template_ws.
If you need to modify their configuration for your own workspace, the easiest way is to copy one of
the examples and place it directly in the `demos` folder.
This will then be versioned with your workspace's commits.
However, changing the folder requires modifying the `compose.yaml` file.
You need to correct the `file:` line so that it points to the correct path of the
`docker/common.yaml` file (containing the main docker settings):
```yaml
x-yaml-anchors:
  base: &base
    extends:
      file: ../../docker/common.yaml  # line to modify
      service: x11_base
```

You must also adapt the symbolic link `.env` so that it references the one located at the root of
the workspace.
From the root of the workspace, execute:
```bash
ln -sfr .env demos/<your_demo_name>/.env
```


# Using VS Code in a dev container

If you use VS Code as your IDE, you can open it in the containerized environment.
You will then have access to auto-completion and be able to browse the files of the embedded Tirrex
workspace located in `/opt/tirrex_ws`.
The IDE terminals will also be in the workspace's ROS environment.
To configure it, you can follow these steps:
* Open the workspace in VS Code (using the bash command `code .` from the root of the workspace)
* Install the _Dev Containers_ extension (Ctrl+Shift+X > "Dev Containers")
* Reopen the workspace in the Dev Container (Ctrl+Shift+P > "reopen in dev container")
* Add the Tirrex workspace to the explorer (File > Add folder to workspace > `/opt/tirrex_ws`)

It is not possible to modify the files in `/opt/tirrex_ws`.
Adding them to the file explorer only allows you to view the complete Tirrex source code.
If you need to make modifications, you will have to clone the Git project corresponding to the
package you want to modify into your workspace.
Local packages will always take precedence when they also exist in the underlay workspace.


# Adding libraries or programs in the docker image

If you want to install programs using `apt install`, you can add them in the
[Dockerfile](Dockerfile).
For example, if you want to install the c/c++ debugger `gdb`, you have to edit the Dockerfile this
way:
```Dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gdb \
    && rm -rf /var/lib/apt/lists/*
```

After that, you have to rebuild the docker image
```bash
docker compose build compile
```

If you want to install missing libraries from your ROS packages, the best way to do that is to
correctly add them in the `package.xml` file of your package and rebuild from scratch the docker
image.
```bash
docker compile build --no-cache compile
```
These libraries will be automatically installed using `rosdep`.
If you want more information about managing these dependencies, you can read the
[rosdep tutorial](https://docs.ros.org/en/humble/Tutorials/Intermediate/Rosdep.html).


# Recommended practices with git

You have to create a different git project for every ROS package (or group of dependent packages)
and handle them using [`vcstool`](https://github.com/dirk-thomas/vcstool).
This is the approach used by tirrex_workspace.
You have to define a `docker/repositories` file that contain the URL of each git project you want to
include in your workspace.
If you want to write it manually, you can take inspiration from the
[repositories](https://github.com/Tirrex-Roboterrium/tirrex_workspace/blob/main/docker/repositories)
file from tirrex workspace, but the easiest way is to generate it from the existing git projects you
already have included in your workspace.
You can generate it using
```bash
./scripts/generate_repositories
```
This is an important step to share your work with others because they can automatically clone all
your project using the same script than tirrex_workspace:
```bash
./scripts/create_ws
```

It is also possible to define several `repositories` file if you want to provide different URLs for
the git projects.
It can be useful if you want to provide URLs with a private token that allows downloading the source
code without an account on the git server.
In this case, you have to specify the path of the repositories you want to use before executing
`create_ws`.
This can be done using the following command:
```bash
echo REPOS_FILE="<path/of/your/repositories/file>" >> .env
```
