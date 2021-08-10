# Server

The entire server packaged into one repository. If you want to run the society yourself, or contribute new features, this is the base repository that you need.

## Running the society

Prerequisites:

- Linux (if you’re developing on Windows, install WSL2)
- Docker and Docker-Compose
- Git

First, clone this repository. Inside you’ll find a script called `run.sh`;`chmod +x` it and execute it without any arguments to start the server. To stop the server run `docker-compose down`, and to delete all user data and results (clean slate) run `docker-compose down -v`

To update the server (can be done while the server is running) run `./run.sh -p` (p for pull)

To configure the server to change the game or any other settings, ensure that you have run the server once already, then modify `config.yml`. Once you are happy with your settings, run `./run.sh -r` (r for reload)

With default settings, you can go to [lvh.me](http://lvh.me) to view the website and start playing!

## Contributing

First, it is recommended that that you follow the above guide and have a working local copy of the society. The following steps will help you to clone all of the relevant repositories and launch the server in development mode. 

Launching development is simple, just run `./run.sh -d` (d for development). You should see several new folders be created within the server directory, each containing the repository with the module corresponding to their name. Anything that you want to change should be contained within one of these folders, and each folder corresponds to a single docker image.

Each repository cloned is linked to the server when running in development mode, so most changes should be reflected automatically. The exceptions are listed below:

- Changes to `web-app` are not synced until `/web-app/build-debug.sh` is executed. 
- `submission-runner` and `matchmaker` must be reloaded with `./run.sh -r`

When in doubt, if something isn’t updating as you change it, run `./run.sh -d` again to sync everything. (There is no need to stop everything first.)

While in debug mode you can also go to [lvh.me:8000](http://lvh.me:8000/) to view the database in an online console.
