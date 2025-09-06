# Use an official Python runtime as the base image (for OS utilities)
FROM python:3.9-slim

# Set environment variables
ENV LANG=C.UTF-8
ENV HUGO_VERSION=0.144.0
ENV HF_SPACE_URL="https://astraos-test.hf.space/"

# Install system dependencies, including Hugo
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    gcc \
    unzip \
    ca-certificates \
    libcurl4-openssl-dev \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install a specific version of Hugo
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz \
    | tar -xz -C /usr/local/bin

# Set working directory
WORKDIR /app

# Copy the Hugo theme and all project files into the container
# COPY ./themes/hugo-brewm /app/themes/hugo-brewm
COPY . .

# Ensure the /app directory (and subdirectories) are writable
RUN chmod -R 777 /app

# Remove any stale Hugo build lock file
# RUN rm -f /app/.hugo_build.lock

# Change ownership of /app to avoid permission issues
RUN useradd -m hugo && chown -R hugo:hugo /app
USER hugo

# Update Hugo modules
# RUN hugo mod tidy

# Build the Hugo site with --noTimes
# RUN hugo --noTimes

RUN hugo --destination /app/public

# Expose the port the Hugo server will use
EXPOSE 7860

# Start the Hugo server with --noTimes (and other flags)
# CMD ["hugo", "server", "--bind", "0.0.0.0", "--port", "7860", "--appendPort=true", "--disableFastRender", "--bind=127.0.0.1", "baseURL=https://astraos-test.hf.space/"]
# CMD ["hugo", "server", "--bind", "0.0.0.0", "--port", "7860", "--appendPort=true", "--disableFastRender", "--noBuildLock", "--noTimes", "--bind=127.0.0.1", "baseURL=https://astraos-dev.hf.space/"]
# CMD ["hugo", "server", "--bind", "0.0.0.0", "--port", "7860", "--appendPort=false", "--disableFastRender", "--noBuildLock", "--noTimes", "--bind=127.0.0.1"]
# CMD ["hugo", "server", "--bind", "0.0.0.0", "--port", "7860", "--disableFastRender"]
CMD ["python", "-m", "http.server", "7860", "--directory", "/app/public"]

