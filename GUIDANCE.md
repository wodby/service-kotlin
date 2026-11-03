# Kotlin on Wodby

What this service adds to the Java service it is based on. The image, build, start command, links and development workspace are the Java service's; check its guidance for those.

## Build a Kotlin project

Kotlin projects build with Gradle: the repository needs the Gradle wrapper (`gradlew` and `gradle/wrapper/`). Kotlin's version is the one the build pins with the Kotlin Gradle plugin; the service's versions (25 and 21) are Java versions. Compile for the oldest Java version the application must run on (`jvmTarget` and Java's `targetCompatibility`).

The service runs one self-contained jar with `java -jar`, so `./gradlew assemble` must leave exactly one runnable jar in `build/libs/`, with the application's dependencies inside and `Main-Class` in its manifest:

- With the Shadow plugin (`com.gradleup.shadow`), set the shadow jar's classifier to empty and the plain jar's to `plain`. Jars ending in `-plain` are not counted. Call `mergeServiceFiles()` so libraries found through `META-INF/services`, such as Ktor's and Netty's, keep working.
- With Ktor's Gradle plugin, `buildFatJar` makes such a jar; add it to `assemble` and mark the plain jar the same way.
- A build with several jars needs `JAVA_BUILD_JAR`, relative to the repository, such as `server/build/libs/server-all.jar`. Add it to the service as a build variable; a development workspace builds at runtime, so give it the runtime scope too.

The application plugin's `installDist` layout (a start script and a `lib/` folder) is not used. Skipping its `distZip` and `distTar` tasks keeps builds and workspace rebuilds shorter.

## Run on Wodby

- Listen on port 8080 on all interfaces, reading `PORT` when it is set. With Ktor's `embeddedServer`, pass `host = "0.0.0.0"`.
- The service is ready when `/` answers with a status below 500. Set `JAVA_READY_PATH`, such as `/healthz`, to check a health route instead; it must then answer 200.
- Ktor's `embeddedServer(...).start(wait = true)` stops on SIGTERM and finishes running requests; keep its shutdown timeout below the service's 30 second grace period.
- Build a JDBC URL from the `DB_*` variables, such as `jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME`, for Exposed, JDBI or plain JDBC.

## Check the result

`./gradlew compileKotlin` in the checkout shows compile errors at once; `./gradlew test` runs the tests, which the service's build skips.
