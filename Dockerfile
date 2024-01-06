FROM --platform=linux/arm64 ubuntu:20.04 as downloader
# FROM arch64v8/alpine

ARG TARGETPLATFORM
ARG VERSION

SHELL ["/bin/bash", "-c"]

RUN apt update -y
RUN apt install -y unzip curl

# RUN apk update && apk add unzip && apk add curl

RUN curl -Lsf https://github.com/LukeChannings/deno-arm64/releases/download/${VERSION}/deno-$(echo $TARGETPLATFORM | tr '/' '-').zip -o ./deno.zip


RUN pwd

RUN unzip ./deno.zip && rm ./deno.zip

FROM --platform=linux/arm64 ubuntu:20.04

COPY --from=downloader /deno /bin/deno
RUN chmod 755 /bin/deno

RUN addgroup --gid 1993 deno
RUN adduser --uid 1993 --gid 1993 deno
RUN mkdir /deno-dir/
RUN chown deno:deno /deno-dir/

ENV DENO_DIR /deno-dir/
ENV DENO_INSTALL_ROOT /usr/local

ARG GIT_REVISION
ENV DENO_DEPLOYMENT_ID=${GIT_REVISION}

RUN deno upgrade --version 1.39.2

COPY . .
RUN deno cache main.ts

EXPOSE 8000

ENTRYPOINT ["/bin/deno"]
CMD ["task", "start"]
