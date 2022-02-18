FROM python:3
LABEL maintainer="Sebastien Teissier"
ADD ./src /src
ADD ./images /images
COPY entry_point.sh /entry_point.sh
COPY requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade pip
RUN pip install -r /requirements.txt
RUN rm -f /requirements.txt
RUN chmod +x /entry_point.sh
EXPOSE 8000
ENTRYPOINT [ "sh", "/app/entry_point.sh" ]

