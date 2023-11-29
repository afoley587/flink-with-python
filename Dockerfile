FROM python:3.9.18-bullseye

ARG FLINK_VER=1.18.0 \
    POETRY_VER=1.6.1

RUN apt update -y \
    && apt-get install -y --no-install-recommends \
    openjdk-17-jdk=17.0.* \
    && pip install poetry==$POETRY_VER \
    && mkdir -p /taskscripts /jars /flink \
    && wget -O /flink/flink.tgz https://dlcdn.apache.org/flink/flink-$FLINK_VER/flink-$FLINK_VER-bin-scala_2.12.tgz \
    && tar -C /flink --strip-components 1 -zxvf /flink/flink.tgz \
    && rm /flink/flink.tgz

WORKDIR /taskscripts

COPY poetry.lock pyproject.toml ./

ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-arm64/

RUN poetry export -f requirements.txt -o requirements.txt --without-hashes \
    && pip install -r requirements.txt \
    && rm -f requirements.txt

ADD https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.11/1.9.2/flink-sql-connector-kafka_2.11-1.9.2.jar /jars

COPY flink_with_python/* ./

ENTRYPOINT ["tail", "-f", "/dev/null"]