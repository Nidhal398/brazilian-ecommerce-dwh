FROM apache/airflow:2.7.1-python3.11
USER root

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        default-jdk \
        git \
        curl \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Donner les permissions sur les scripts Talend au démarrage
COPY --chown=airflow:airflow . .

USER airflow

RUN pip install apache-airflow-providers-postgres