# on_install hooks

Here you can do custom installation of any dependencies. The general structure looks like this:

```
.
├── 01-my_dep
│   ├── python_package.tar.gz
│   ├── dep_install
│   └── global_install
└── README.md
```

Note that there are 2 kinds of installation hooks. You don't have to use both of them in the same folder. We will go over both of the methods and what their differences are:

# dep_install

This script will be executed within the hummingbot Conda-environment, either at runtime or during Docker build. Therefore, you can:

- build or install pip packages made available in your strategies
- install native dependencies (Rust, CLI tools, etc)


It'll be available right in the hummingbot environment after build or on the first run.
**Note!** Only finally packages will be included in the Conda environment! Anything you used to build said package (if you build it from source), for example, installing the Rust compiler to build a native Python package written in Rust will be omitted! This is to save space and keep only that what you really need.

If your command starts with `pip install`, this is likely your best bet!

# global_install

Like `dep_install`, this will also run in the hummingbot Conda-environment. However, any result during this stage of the build will be saved in the final image! This is mainly useful for installing native dependencies and modules (i.e `apt-get`), having them available throughout the lifecycle of your image.

# Notes

on_install hooks are executed on alphabetical order, this allows you to keep a clean set of files, but still maintain order in case one installation script depends on the other.

on_install hooks need to have execution rights. Make sure to run `chmod a+x dep_install` and/or `chmod a+x global_install` depending on your script before building an image.