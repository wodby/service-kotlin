ARG WODBY_BASE_IMAGE
FROM ${WODBY_BASE_IMAGE}

ARG COPY_FROM
ARG COPY_TO=/usr/src/app
COPY --chown=wodby:wodby ${COPY_FROM} ${COPY_TO}

# Build a Gradle project that applies the application plugin with its own
# wrapper, and link the start script installDist writes as `app`. Gradle's
# downloads are left out of the image.
RUN if [ -f gradlew ]; then \
      set -e; \
      export GRADLE_USER_HOME=/tmp/gradle; \
      sh ./gradlew --no-daemon --console=plain installDist; \
      launchers=$(find build/install */build/install -mindepth 3 -maxdepth 3 -path '*/bin/*' -type f ! -name '*.bat' 2>/dev/null || true); \
      if [ "$(printf '%s' "${launchers}" | grep -c .)" != 1 ]; then \
        echo "Expected one start script from installDist, found: ${launchers:-none}. Use a Dockerfile of your own." >&2; \
        exit 1; \
      fi; \
      ln -s "${COPY_TO}/${launchers}" /home/wodby/.local/bin/app; \
      rm -rf /tmp/gradle .gradle .kotlin; \
    fi

CMD ["app"]
