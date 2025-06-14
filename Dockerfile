FROM sbtscala/scala-sbt:eclipse-temurin-jammy-17.0.9_9_1.9.7_3.3.1 AS BUILD

WORKDIR /opt/build

COPY . /opt/build

RUN sbt compile
RUN sbt Univeral/stage

FROM eclipse-temurin:17.0.9_9-jre-jammy

WORKDIR /opt/app

COPY --from=BUILD /opt/build/target/universal/stage /opt/app

CMD ["sh", "-c", "bin/recipoir"]