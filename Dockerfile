# --- Etapa de Construcción ---
FROM elixir:1.16-otp-26 AS builder

# Configurar variables de entorno para producción
ENV MIX_ENV=prod

# Instalar dependencias del sistema necesarias
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*{apt,cache,log}*

WORKDIR /app

# Instalar Hex y Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copiar archivos de configuración de dependencias
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# Copiar el resto del código y compilar
COPY assets assets
COPY lib lib
COPY priv priv
COPY config config

RUN mix compile
RUN mix assets.deploy

# Generar la Release (el ejecutable empaquetado)
RUN mix release

# --- Etapa de Ejecución ---
FROM debian:bookworm-slim AS runner

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
    && apt-get clean && rm -f /var/lib/apt/lists/*{apt,cache,log}*

# Configurar el locale para evitar errores de encoding
RUN sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app

# Copiar la release desde la etapa builder
COPY --from=builder /app/_build/prod/rel/investment_wallet ./

# Variable de entorno para el puerto
ENV PORT=4000
ENV PHX_SERVER=true

CMD ["bin/investment_wallet", "start"]