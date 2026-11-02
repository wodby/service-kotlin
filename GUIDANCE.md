# Kotlin on Wodby

What Wodby sets up for an application that runs on this service. Check it before changing the build, the port or connection settings in the code.

## Versions

The service's versions are Java (JDK) versions: 25 and 21, both on Eclipse Temurin. Kotlin's version is whatever the project's Gradle build pins with the Kotlin plugin. Compile for the oldest JDK the application must run on (`jvmTarget` and Java's `targetCompatibility`).

## Build and start

The service's Dockerfile copies the repository to `/usr/src/app` and, when `gradlew` is at its root:

1. runs `./gradlew installDist` with the project's own Gradle wrapper; the project must apply Gradle's `application` plugin;
2. links the start script that `installDist` writes (`build/install/<name>/bin/<name>`) as `app`.

The container starts that script as `app`. Exactly one start script must result; a multi-project build that installs several applications needs a Dockerfile of its own. Gradle's downloads are not kept in the image. A pipeline that passes a Dockerfile from the repository (`wodby ci build kotlin -f Dockerfile`) uses that file instead; it must still end with a command that starts the server.

Gradle itself is not installed in the image: the repository must contain the Gradle wrapper (`gradlew` and `gradle/wrapper/`). Maven projects need a Dockerfile of their own.

- The application must listen on port 8080, on all interfaces. That is the port of the service's HTTP endpoint. The service sets no `PORT` variable in a deployed environment: default to 8080 in the code.
- The JVM sizes its heap from the container's memory limit: by default a quarter of it. Set `JAVA_OPTS` (read by the start script) to change it, for example `-XX:MaxRAMPercentage=75`.
- The service sets no other variable for the application and generates no configuration file.
- The service declares no volume of its own: files written inside the container are lost when it is replaced.
- The container is ready once port 8080 accepts connections. Nothing restarts it for a slow start.

## Linked services

Links to other services reach the application as environment variables. Nothing in the image reads them: the application reads them itself. Do not hardcode hosts or credentials.

| Link | Variables |
| --- | --- |
| Database (MariaDB, MySQL or PostgreSQL) | `DB_HOST`, `DB_PORT`, `DB_NAME` (also `DB_DATABASE`), `DB_USERNAME`, `DB_PASSWORD`, `DB_DRIVER` (also `DB_CONNECTION`) |
| Mail | `SMTP_HOST`, `SMTP_PORT` |
| Redis or Valkey | `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` |

All three links are optional. A variable is present only while its link exists and the linked service is enabled. The mail link carries no credentials. A JDBC URL is built from the database variables in the code, for example `jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME`.

## Environment

- `WODBY_HOSTS` is a JSON array of the environment's hosts, not a comma-separated string. `WODBY_PRIMARY_HOST` and `WODBY_PRIMARY_URL` are the canonical ones for links generated outside a request.
- `WODBY_APP_SERVICE_NAME` is this service's host name inside the environment. Other services reach the application at that name on port 8080.
- `WODBY_ENV_TYPE` tells a development environment from a production-like one.

## In a development workspace

- The checkout is mounted at `/usr/src/app`. The application is built from it with `./gradlew installDist` and run, and the checkout is watched: when a project file changes, it is built again and the application is restarted with the new build, in the same container, usually within a few seconds once Gradle is warm. Nothing has to be restarted or deployed for a code change. A build that fails leaves the previous build running; Gradle's errors are in the service's logs.
- Project files are the files Git tracks plus untracked files that are not ignored. `.gradle`, `.kotlin` and untracked `build` directories don't count, so `./gradlew test` run by hand doesn't restart the application.
- Workspace setup runs `workspace-gradle prepare`: it downloads Gradle and the dependencies and builds the application once. The first build takes a few minutes.
- The project built and run is the root project; `WORKSPACE_GRADLE_PROJECT` on the service selects another one, such as `:server`. It must apply the `application` plugin. `WORKSPACE_GRADLE_COMMAND` replaces the start command.
- `HOST` and `PORT` are set, to `0.0.0.0` and `8080` by default. The application must read them or listen on 8080 anyway.
- Builds keep everything they write in `.wodby-workspace/` in the checkout: Gradle's home and caches, build output and the installed application. The checkout's own `build`, `.gradle` and `.kotlin` directories are not used, and `.wodby-workspace/` is kept out of Git status without touching `.gitignore`.
- A change to variables or linked services still needs a deployment of the environment.

## Check the result

- `curl -s -o /dev/null -w '%{http_code}' localhost:8080` from the container shows whether the application answers on the expected port.
- `./gradlew build` in the checkout shows compile errors and test failures at once; the service's logs show them too when a change does not appear.
