# Kotlin service for Kubernetes on Wodby

Build and run Kotlin applications on Kubernetes with Wodby.

This repository defines the Wodby service manifests and operational
configuration for Kotlin.

- [Browse Wodby services](https://wodby.com/services)
- [Wodby service documentation](https://wodby.com/docs/2.0/services/)
- [Service manifest reference](https://wodby.com/docs/2.0/services/template/)

## Start with a boilerplate

Use one of the boilerplates exposed by this service to start with compatible
build configuration and Wodby CI:

- [Kotlin boilerplate](https://github.com/wodby/kotlin-boilerplate)

## Wodby stacks using this service

- [Kotlin application stack](https://github.com/wodby/stack-kotlin)

## Service overview

| Property | Manifest configuration |
| --- | --- |
| Service name | `kotlin` |
| Type | Application service |
| Versions | Java `25` by default, `21` |
| Workloads | `main` (Deployment), primary; scalable |
| Containers | `kotlin` using `wodby/jdk`, build target |
| Endpoints | `kotlin`: HTTP 8080 (main) |
| Service links | DBMS (`db`), optional, Mail Transfer Agent (`sendmail`), optional, Redis, optional |
| Application build | Git source connection enabled; Dockerfile: `Dockerfile`; boilerplates: Kotlin boilerplate |
| Helm | chart `oci://registry-1.docker.io/wodby/stateless`; version `0.4.0` |
| Configuration | 1 integration slots |

## Use this service

Use this service through [Kotlin application stack](https://github.com/wodby/stack-kotlin), or reference `kotlin` from a custom
Wodby stack.

A service is a reusable component and does not deploy by itself. The stack
defines its links, settings, versions, resources, and relationship to the rest
of the application.

## Maintain a custom version

1. Fork this repository.
2. Edit the service manifest and referenced files.
3. Import the repository as a [Git-backed service](https://wodby.com/docs/2.0/services/create/#create-a-git-backed-service).
4. Reference the service from a stack manifest.

Keep service, workload, container, endpoint, link, volume, config, and
derivative names stable unless dependent stacks and app-level overrides are
updated at the same time.

Validate the manifests with:

```bash
wodby service validate-manifest service.yml --org <org-id>
```

See the [service manifest reference](https://wodby.com/docs/2.0/services/template/) and the [managed services index](https://github.com/wodby/services).

## Versions

The service's versions are Java (JDK) versions on Eclipse Temurin: 25 (default) and 21, both long-term support
releases. Kotlin's version comes from the project's Gradle build. See [GUIDANCE.md](GUIDANCE.md) for the build and
runtime contract.

## Development workspaces

`workspace-gradle prepare` downloads Gradle and the dependencies with the project's Gradle wrapper and builds the
application once. `workspace-gradle start` builds it with `installDist` and runs it, then builds again and restarts
the application whenever a project file in the checkout changes. `WORKSPACE_GRADLE_WATCH=0` turns that off.
`WORKSPACE_GRADLE_PROJECT` selects a subproject such as `:server` (the root project by default);
`WORKSPACE_GRADLE_COMMAND` overrides startup. `HOST` and `PORT` default to `0.0.0.0` and `8080`, but the application
must read them. Build output, Gradle's caches and the installed application are kept in `.wodby-workspace/`, so the
checkout's tracked files and its own build directories are not written.

Requires a runtime image declaring workspace contract version 1. Ordinary and development option tags must use matching revisions.
