# Advanced hummingbot Docker

When working on the hummingbot-source, I found a need for a custom Docker image that I can simply mount my source code to and run whenever I needed it to.

At the same time, when my strategies or source was all ready to be used in live trading (i.e. production), I wanted to be able to upload a container to my Raspberry Pi and let it run without having to rebuild from source again (Which would be slow, especially if you add native modules to the mix), all of this preferably as lightweight as possible.

This is exactly why I made this new setup! Thanks to some clever trickery and out of-the-box thinking, this Docker setup uses the same codebase for creating development as well as production Docker images!

It's not meant to compete with hummingbot's Docker setup but rather accommodate.

### Differences between my and hummingbot's Docker setup

hummingbot | Advanced Docker HB
---|---
Distributes compiled Docker images where you can mount a directory with your config | Lets you build the full image based on your current source directory (can be your fork or the official repo)
Focuses on production (to edit the source code you need to fork the project and rebuild the Docker image) | Can mount a local hummingbot directory to the Docker image featuring live edits, or compile to a new image with your source and current strategy configuration included
Ships with the packages hummingbot provides (Conda environment) | You can easily install your own pip packages inside the hummingbot Conda environment. You can also compile from source (this allows one to easily upload, say, Rust modules) (See: [on_install hooks](./HBDocker/on_install/README.md))

### Other nice things
- Cache is stored in a hidden folder outside the Docker image. Even if you re-run the development Docker image, the slow process of getting the Python environment ready will be much faster next time.

## How to start
Advanced hummingbot Docker runs both in development mode (mounted source directory) or production mode (all strategies + configurations rolled into a single image).

Each mode is explained in their own chapter.
For both modes, I assume you have Docker and docker-compose installed.

### For both modes
These instructions should be executed first, no matter what mode you choose.

- Clone this repo to your device
- Download the hummingbot source and place it *in the root directory* of this repo.
    - This could simply be running `git clone --depth=1 https://github.com/CoinAlpha/hummingbot.git` inside the folder where you cloned this repo (or copying your already cloned source to said folder)
    - It should look like this:
        ```
        .
        ├── build_production_image
        ├── docker-compose.dev.yml
        ├── docker-compose.prod.example.yml
        ├── docker-compose.prod.yml
        ├── EFDiscordBot
        ├── HBDocker
        ├── hummingbot << I am new!
        ├── LICENSE
        └── README.md
        ```

### Run in development mode

- Simply `cd` to the directory of this repo and rename docker-compose.dev.example.yml to docker-compose.dev.yml.
- You can add custom containers aside the bot if you wish, like PostgreSQL.
- Run `docker-compose -f docker-compose.dev.yml up -d --build`
- After having started it, the Docker container will do some one-time installation, like the hummingbot dependencies (or your own, if you defined any). The reason this happens on runtime and not during creation is so that it's possible to do all of this on your mounted source directory. For production-mode this won't happen.

### Run in production mode
**Note**: Production mode will include **ALL** your configuration including (encrypted) API keys. The purpose of this image is to deploy reliably without machine-dependent bugs. You should never upload this image to a public place like Docker hub.

In the tutorial below I will use `docker save` and `load` which are completely local and safely avoids sharing sensitive details.

- To start building the production image, `build_production_image` from your cloned repo.

    - It'll start building both for amd64 and arm64 (usable for Raspberry Pi)

- After a while, you will have an image named `advanced_hummingbot_prod_amd64` and `advanced_hummingbot_prod_arm64` if you had the right setup for ARM compilation!

- Now, you can call `docker save advanced_hummingbot_prod_amd64 | gzip > advanced_hummingbot_prod_amd64.tar.gz` (replace amd64 with arm64 for Raspberry Pi) to export to a compressed image file.

- Take your file to your destination (i.e a server or Raspberry Pi), and call `docker load < advanced_hummingbot_prod_amd64.tar.gz` (replace amd64 with arm64 for Raspberry Pi)

- Rename docker-compose.prod.example.yml to docker-compose.prod.yml, and copy it to the same destination.

- Adjust the contents of the file as you prefer
    - Mandatory changes are setting your password and strategy name
    - Optional changes include: launching more than 1 bot, include other Docker images your bot depends on...

- Now you can run `docker-compose -f docker-compose.prod.yml up -d` and your bots are running!

- You can call `docker-compose -f docker-compose.prod.yml ps` to find your image names, and run `docker attach <name>` to get in the hummingbot panel to control the bot. Use `ctrl+p` followed by `ctrl+q` to get out of it.

- Updating your bot? Simply re-run `build_production_image` and repeat the steps to export, upload and load the Docker image on your destination!

# Configuration

-  [How to install dependencies and custom software?](./HBDocker/on_install/README.md)

# Tested devices

Device | Status | Comments
---|---|---
Raspberry Pi 4 [1GB RAM] | ✅ | Tested on NixOS
Odroid M1 [8GB RAM] | ✅ | Tested on SkiffOS and Ubuntu Server

Have you tested your own device? Feel free to submit a PR and add it!