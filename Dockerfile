FROM futureys/claude-code-python-development:20260609002000
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
