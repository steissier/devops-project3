FROM python:3
LABEL maintainer="Sebastien Teissier"
ADD ./src /src
ADD ./images /images
COPY entry_point.sh /entry_point.sh
RUN pip install Django
RUN pip install psycopg2
RUN pip install Pillow
RUN pip install requests
EXPOSE 80
ENTRYPOINT [ "sh", "/entry_point.sh" ]

