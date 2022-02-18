FROM python:3
LABEL maintainer="Sebastien Teissier"
ADD ./src /app/src
ADD ./images /app/images
COPY entry_point.sh /app/entry_point.sh
RUN python3 -m pip install --upgrade pip
RUN pip install -r ./requirements.txt
RUN chmod +x /app/entry_point.sh
EXPOSE 8000
ENTRYPOINT [ "sh", "/app/entry_point.sh" ]

