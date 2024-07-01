FROM python:3.9.18-bullseye

ARG FLINK_VER=1.18.1 \
    POETRY_VER=1.6.1

RUN apt update -y \
    && apt-get install -y --no-install-recommends \
    openjdk-11-jdk=11.0.* \
    && pip install poetry==$POETRY_VER \
    && mkdir -p /taskscripts /jars /flink \
    && wget -O /flink/flink.tgz https://dlcdn.apache.org/flink/flink-$FLINK_VER/flink-$FLINK_VER-bin-scala_2.12.tgz \
    && tar -C /flink --strip-components 1 -zxvf /flink/flink.tgz \
    && rm /flink/flink.tgz

WORKDIR /taskscripts

COPY poetry.lock pyproject.toml ./

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-arm64/

RUN poetry export -f requirements.txt -o requirements.txt --without-hashes \
    && pip install -r requirements.txt \
    && rm -f requirements.txt

ADD https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.1-1.18/flink-sql-connector-kafka-3.0.1-1.18.jar /jars
COPY flink_with_python/* ./
