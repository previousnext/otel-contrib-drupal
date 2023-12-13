FROM skpr/php-fpm:8.3-dev-v2-edge

ADD php-fpm.conf /etc/php/php-fpm.conf

USER root

RUN apk --update --no-cache add \
     php8.3-opentelemetry \
     php8.3-grpc

USER skpr

# OpenTelemetry Overrides.
# ENV OTEL_SERVICE_NAME=my-application
#     OTEL_EXPORTER_OTLP_ENDPOINT=http://collector:4317
#     OTEL_PROPAGATORS=baggage,tracecontext

# OpenTelemetry Defaults.
# ENV OTEL_PHP_AUTOLOAD_ENABLED=true \
#    OTEL_TRACES_EXPORTER=otlp \
#    OTEL_EXPORTER_OTLP_PROTOCOL=grpc