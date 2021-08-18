# Server

The entire server packaged into one repository. If you want to run the society yourself, or contribute new features, this is the base repository that you need.

## Running the society

Prerequisites:

- Linux (if you’re developing on Windows, install WSL2)
- Docker and Docker-Compose
- Git

First, clone this repository. Inside you’ll find a script called `run.sh`. `chmod +x run.sh` it and execute `./run.sh` to start the server.

With default settings, you can go to [lvh.me](http://lvh.me) to view the website and start playing!

To stop the server run `docker-compose down`, and to delete all user data and results (clean slate) run `docker-compose down -v`

To update the server (can be done while the server is running) run `./run.sh -p` (p for pull)

To configure the server to change the game or any other settings, ensure that you have run the server once already, then modify `config.yml`. Once you are happy with your settings, run `./run.sh -r` (r for reload)

### Configuration

Firstly, to change the port number, modify the port number within the `.env` file.

The other options within `config.yml` are as follows:

```yaml
db_connection: the database connection string with username and password. For security reasons you should change the username and password in both this and in the .env file. Default value: "postgresql://aisoc:aisoc@database"
debug: Whether to give debug information on faulty API requests and print debug information in all of the consoles. Default value: false
secure: Adds extra security if the site is being hosted over https. Set to true if you have an ssl certificate. Default value: false
profile: Adds timing debug output on API endpoints. Default value: false
soc_name: The name of your society, as seen on your webpage. Default value: "AIWarSoc"
google_client_id: The OAouth2 client ID for the google login to use. Go to https://console.cloud.google.com/apis/credentials to create one for your app. The default value only works for lvh.me
allowed_email_domain: The domain that users must have to be able to log in. If you are a Uni society, you should set this to your uni domain, or set to ~ to allow any domain. 
max_repo_size_bytes: Checked per submission
initial_score: Where you start on the leaderboard. Default value: 1000
score_turbulence: The coefficient in the ELO formula. Default value: 0.5
admin_emails: The emails of the people that are admins. This list only takes effect when a user logs in for the first time, so you can't promote or demote people without deleting their account too. Default value: []
gamemode:
  id: chess
  options:
    chess960: true
    turn_time: 10
    player_turn_time: The turn timer for playing the AIs on the website, because people need more time than AIs apparently. 
front_end:
  server_name: The domain people connect to
  access_token_expire_minutes: How long before you need to log in again
  access_token_algorithm: "HS256"
matchmaker:
  target_seconds_per_game: If a game takes less than this long, pause for a bit. Makes the rate of games more regular.
  matchmakers: No. of threads to run AIs in. 
localisation: Change these if you need to translate the site etc.

```



## Contributing

First, it is recommended that that you follow the above guide and have a working local copy of the steps above. The following steps will help you to clone all of the relevant repositories and launch the server in development mode. 

Launching development is simple, just run `./run.sh -d` (d for development). You should see several new folders be created within the server directory, each containing the repository with the module corresponding to their name. Anything that you want to change should be contained within one of these folders, and each folder corresponds to a single docker image.

Each repository cloned is linked to the server when running in development mode, so most changes should be reflected automatically. The exceptions are listed below:

- Changes to `web-app` are not synced until `/web-app/build-debug.sh` is executed. 
- Changes to `submission-runner` and `matchmaker` must be reloaded with `./run.sh -r`

When in doubt, if something isn’t updating as you change it, run `./run.sh -d` again to sync everything. (There is no need to stop everything first.)

While in debug mode you can also go to [lvh.me:8000](http://lvh.me:8000/) to view the database in an online console using the username and password specified in your `.env` file.

You may want to download the react developer plugin for your browser to be able to see the source of the website if you plan to develop anything on the front-end.

## Documentation

```
                         ┌──Docker────────────────────────────────────────────────────────────────────────────┐
                         │                                           ┌──────────────────┐                     │
                         │                                           │                  │                     │
                         │                               ┌─────────► │     Web-App      │                     │
                         │                               │           │ (Static Content) │                     │
                         │                        "/" Get│Requests   └──────────────────┘                     │
                         │    ┌─────────────────┐        │                                                    │
─ Post/Get Requests ─────┼──► │                 │ ◄──────┘                                                    │
                         │    │    Web-Server   │                                                             │
Web Socket Requests ─────┼──► │ (Reverse proxy) │ ◄──────┐                                                    │
                         │    └─────────────────┘        │                                                    │
                         │                        "/api/"│Requests  ┌────────────────────┐        ┌─────────┐ │
                         │                               │          │                    │        │         │ │
                         │                               └────────► │      Web-Api       │ ◄────► │  Redis  │ │
                         │                                          │ (Dynamic Requests) │        │         │ │
                         │                                          └────────────────────┘        └─────────┘ │
                         │                                           │       ▲        ▲                       │
                         │                                           ▼       │        │                       │
                         │                           ┌────────────────┐      │        │                       │
                         │                       ┌───┘                │      │        └─────┐                 │
                         │                       │     Submissions    │      │              │                 │
                         │                       │      [Volume]      │      │              │                 │
                         │                       └────────────────────┘      │              │                 │
                         │                                     │             │              ▼                 │
                         │                                     │       ┌─────┘       ┌──────────────┐         │
                         │ ┌──Docker in Docker───────┐         │       │             │              │         │
                         │ │                         │         │       │ Websocket   │   Database   │         │
                         │ │     ┌─────────────┐     │         │       │(Games in    │              │         │
                         │ │     │             │     │         │       │  Browser)   └──────────────┘         │
                         │ │     │ Player AI 1 │ ◄───┼──┐      │       │                    ▲                 │
                         │ │     │  (Sandbox)  │     │  │      ▼       ▼                    │                 │
                         │ │     └─────────────┘     │  │   ┌──────────────┐                │                 │
                         │ │                         │  └─► │  Submission  │                │                 │
                         │ │                         │      │    Runner    │                │                 │
                         │ │                         │  ┌─► │              │                │                 │
                         │ │     ┌─────────────┐     │  │   └──────────────┘                ▼                 │
                         │ │     │             │     │  │          ▲                 ┌──────────────┐         │
                         │ │     │ Player AI 2 │ ◄───┼──┘    "/run"│Get Request      │              │         │
                         │ │     │  (Sandbox)  │     │             └───────────────► │  Matchmaker  │         │
                         │ │     └─────────────┘     │                               │              │         │
                         │ │                         │                               └──────────────┘         │
                         │ └─────────────────────────┘                                                        │
                         └────────────────────────────────────────────────────────────────────────────────────┘
```

