# Use Ubuntu as base
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set up a non-root user
RUN groupadd -r flutter && useradd -r -g flutter flutter
RUN mkdir -p /home/flutter && chown -R flutter:flutter /home/flutter

# Set up Flutter
USER flutter
WORKDIR /home/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1
ENV PATH="/home/flutter/flutter/bin:${PATH}"
RUN flutter precache
RUN flutter doctor -v

# Set working directory for the app
WORKDIR /home/flutter/app

# Copy the pubspec files and get dependencies
COPY --chown=flutter:flutter pubspec.* ./
RUN flutter pub get

# Copy the rest of the code
COPY --chown=flutter:flutter . .

# Build
RUN flutter build web --release

# Production stage
FROM nginx:alpine
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]