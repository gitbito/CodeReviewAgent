FROM docker:20.10

RUN apk add bash

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


ENTRYPOINT ["bash", "/entrypoint.sh"]