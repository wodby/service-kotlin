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

The included boilerplate uses Ktor 3 and Kotlin 2.4 and supports Java 21 and 25.

## Wodby stacks using this service

- [Kotlin application stack](https://github.com/wodby/stack-kotlin)

## Service overview

| Property | Manifest configuration |
| --- | --- |
| Service name | `kotlin` |
| Type | Application service |
| Inherits from | [`java`](https://github.com/wodby/service-java) with version constraint `^1.0.0` |
| Application build | Git source connection enabled; Dockerfile: `Dockerfile`; boilerplates: Kotlin boilerplate |

## Use this service

Use this service through [Kotlin application stack](https://github.com/wodby/stack-kotlin), or reference
`kotlin` from a custom Wodby stack.

A service is a reusable component and does not deploy by itself. The stack
defines its links, settings, versions, resources, and relationship to the rest
of the application.

The service adds nothing to the Java service's runtime: links set the same
component variables (`DB_*`, `DATABASE_URL`, `REDIS_*`, `SMTP_*`), and the
service is ready when `/` answers below 500.

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
wodby service validate-manifest service.yml --include GUIDANCE.md --org <org-id>
```

See the [service manifest reference](https://wodby.com/docs/2.0/services/template/) and the [managed services index](https://github.com/wodby/services).

## Development workspaces

The workspace runtime comes from the Java service: the checkout is built with
its Gradle wrapper and the application restarts with the new build whenever a
file changes. See [GUIDANCE.md](GUIDANCE.md) for the jar the build must produce.

Requires a runtime image declaring workspace contract version 1. Ordinary and development option tags must use matching revisions.
