FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates curl \
       mono-devel \
       apache2 \
       libapache2-mod-mono \
       mono-apache-server4 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://dist.nuget.org/win-x86-commandline/v5.11.0/nuget.exe \
      -o /usr/local/bin/nuget.exe \
    && printf '#!/bin/sh\nexec mono /usr/local/bin/nuget.exe "$@"\n' > /usr/local/bin/nuget \
    && chmod +x /usr/local/bin/nuget

WORKDIR /app
COPY . /app

RUN nuget restore LegacyEcommerce.sln -PackagesDirectory /app/packages -NonInteractive
RUN xbuild LegacyEcommerce.sln /p:Configuration=Debug /verbosity:minimal

# Apache will listen on 8080 inside the container.
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && rm -f /etc/apache2/sites-enabled/000-default.conf \
    && (a2enmod mod_mono || a2enmod mono || true)

COPY docker/web/legacyshop-apache.conf /etc/apache2/sites-available/legacyshop.conf
RUN a2ensite legacyshop

EXPOSE 8080

CMD ["apachectl", "-D", "FOREGROUND"]
