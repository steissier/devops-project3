FROM python:3
NAME webapp
LABEL maintainer="Sebastien Teissier"

ADD ./src /src
ADD ./images /images
COPY entry_point.sh /entry_point.sh
EXPOSE 80
ENTRYPOINT [ "sh", "/entry_point.sh" ]

