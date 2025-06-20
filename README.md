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

You first need to install tirrex_workspace by following instructions in the
[README of this workspace](https://github.com/Tirrex-Roboterrium/tirrex_workspace).
If you are an INRAE developer, you have to follow the specific instructions (there is a section
after installation) and use the repository from the INRAE forge.
You have to name this workspace `tirrex_workspace` or `tirrex_ws`.

Once you finished installing tirrex_workspace, clone this project at the same level as
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


# Best practices with git

To save and distribute your work, the first thing you have to do is to fork this project somewhere
else.
This way, you can make your own changes and save it in your own git server.
Regarding the ROS packages you will create, there are different approaches to handle them:

### Use a unique git project

You handle all the source code of your packages directly from the git project of this workspace.
It is easier to use because you only have one git project to handle fro everything, but it is more
complicated to share your work with people that work on other project or outside your laboratory
because you cannot give the package alone.
You also have to ignore the path of the git project of other ROS packages if you want to include
them in your workspace.

Advantages:
* only one git project to handle

Disadvantages:
* cannot share the packages alone
* require to add in the gitignore the path of packages from other people

### Use several git project with VCS

You can create a different git project for every package (or group of dependent packages) and handle
them using [`vcstool`](https://github.com/dirk-thomas/vcstool).
This is the approach used by tirrex_workspace.
You have to define a `docker/repositories` file that contain the URL of each git project you want to
include in your workspace.
This file can be created using `vcs import` (read the documentation for more information).
You can automatically clone all your project using the provided script `create_ws`.
It is also possible to define several `repositories` file if you want to provide different URLs for
the git projects.
It can be useful if you want to provide URLs with a private token that allows downloading the source
code without an account on the git server.

Advantages:
* allow sharing the packages alone
* provide several ways to get the packages
* can work with packages that does not use git

Disadvantages:
* require to make commits in several git project
* VS-code does not handle easily several git project (use git from the terminal)
* ignore the `src` directory

### Use git submodules 

It is possible to include git projects inside another one using _git submodules_.
It is similar to the previous method but instead of using the `docker/repository` file, you create
(using git commands) a `.gitmodules` file that contain the path and the URL of each git project you
want to include in your workspace.
However, it is not possible to provide multiple URL for a same project.
When you commit changes in one of your ROS package (one of the submodules), the change will be
detected by the main git project (your workspace).
You can then decide to make a commit in your main project to save the new version of this package.

Advantages:
* allow sharing the packages alone
* all the git projects are managed by the main git project
* does not require specific tools like `vcs`
* VS-code handles it correctly

Disadvantages:
* require to make commits in several git project (submodules)
* VS-code does not handle easily several git project
* require to undertstand how git submodule works
