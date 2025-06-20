This project is a ROS2 workspace that extends the tirrex_workspace.
Its aim is to provide a simple way to work with tirrex and TSCF developments without having to
recompile everytime the packages of the tirrex workspace (there are more thant 150 of them).
To do that, it exploits the concept of
[underlay/overlay](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html#source-the-overlay)
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

You first need to install tirrex_workspace by following instructions in the
[README of this workspace](https://github.com/Tirrex-Roboterrium/tirrex_workspace).
If you are an INRAE developer, you have to follow the specific instructions (there is a section
after installation) and use the repository from the INRAE forge.
You have to name this workspace `tirrex_workspace` or `tirrex_ws`.

Once you finished installing tirrex_workspace, you can now clone this project at the same level as
tirrex_workspace.
You have to choose a different name than `template_ws` because it will create a docker image with
the same name.
The best idea is to name it like your research project or a short title of your PhD thesis.
```bash
git clone git@.../template_ws name_of_your_choice_ws
cd name_of_your_choice_ws
```

Execute the script `create_env` to create a `.env` that will contain some environment variables
useful to build the docker images.
```bash
./scripts/create_env
```

Now you can compile the workspace
```bash
docker compose run --rm compile
```

The first time, this command will create a docker image with the name of your workspace.
This image is based on the one of tirrex_workspace.
Regarding the compilation, it will do nothing because you don't have any package at the moment.
You can now create your own ROS package in `src` directory and start working!

You can open a shell inside the ROS environment using
```bash
docker compose run --rm bash
```
This command starts an interactive docker container in your workspace.
Everything is already sourced, so you can execute any `ros2 run` or `ros2 launch` with a package of
your workspace or tirrex_workspace.


# Adding library or programs in the docker image

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
These libraries will be automatically installed using
[rosdep](https://docs.ros.org/en/humble/Tutorials/Intermediate/Rosdep.html).
