FROM docker.io/debian:bookworm

ENV TZ UTC
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN set -x; \
    groupadd -g 1000 odoo \
    && useradd -ms /bin/bash -g 1000 -u 1000 odoo

RUN set -x; \
    apt-get update -y \
    && apt-get install -y wget \
    && wget -qO /etc/apt/trusted.gpg.d/pgdg.gpg.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    && echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends postgresql-client-15 \
    && wget -qO wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf wkhtmltox.deb \
    && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    dirmngr \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-mono \
    geoip-database \
    gnupg \
    gsfonts \
    inetutils-ping \
    libgnutls-dane0 \
    libgts-bin \
    libpaper-utils \
    locales \
    nodejs \
    npm \
    python3 \
    python3-babel \
    python3-chardet \
    python3-cryptography \
    python3-cups \
    python3-dateutil \
    python3-decorator \
    python3-docutils \
    python3-feedparser \
    python3-freezegun \
    python3-geoip2 \
    python3-gevent \
    python3-greenlet \
    python3-html2text \
    python3-idna \
    python3-jinja2 \
    python3-ldap \
    python3-libsass \
    python3-lxml \
    python3-markupsafe \
    python3-num2words \
    python3-ofxparse \
    python3-olefile \
    python3-openssl \
    python3-paramiko \
    python3-passlib \
    python3-pdfminer \
    python3-phonenumbers \
    python3-pil \
    python3-pip \
    python3-polib \
    python3-psutil \
    python3-psycopg2 \
    python3-pydot \
    python3-pylibdmtx \
    python3-pyparsing \
    python3-pypdf2 \
    python3-pytzdata \
    python3-qrcode \
    python3-renderpm \
    python3-reportlab \
    python3-reportlab-accel \
    python3-requests \
    python3-rjsmin \
    python3-serial \
    python3-setuptools \
    python3-stdnum \
    python3-urllib3 \
    python3-usb \
    python3-vobject \
    python3-werkzeug \
    python3-xlrd \
    python3-xlsxwriter \
    python3-xlwt \
    python3-zeep \
    shared-mime-info \
    unzip \
    xz-utils \
    zip

RUN set -x; \
    wget -qO /usr/share/GeoIP/GeoLite2-ASN.mmdb https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-ASN.mmdb \
    && wget -qO /usr/share/GeoIP/GeoLite2-City.mmdb https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb \
    && wget -qO /usr/share/GeoIP/GeoLite2-Country.mmdb https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-Country.mmdb

RUN set -x; \
    pip3 install --break-system-packages ebaysdk google-auth

RUN set -x; \
    npm -g i rtlcss

RUN set -x; \
    rm -rf /var/lib/apt/lists/*

RUN set -x; \
    mkdir -p /opt/odoo && chown odoo:odoo /opt/odoo

VOLUME ["/opt/odoo"]

# Expose Odoo services
EXPOSE 8069 8072

ENV ODOO_RC /opt/odoo/conf/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Copy entrypoint script
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Set default user when running the container
USER odoo

WORKDIR "/opt/odoo"
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo-bin"]
