FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ca-certificates \
    gnupg \
    xvfb \
    x11vnc \
    openbox \
    python3 \
    python3-pip \
    python3-venv \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libasound2 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libdrm2 \
    libxfixes3 \
    libxkbcommon0 \
    libatspi2.0-0 \
    libxshmfence1 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC
RUN wget -qO- https://github.com/novnc/noVNC/archive/refs/tags/v1.6.0.tar.gz \
    | tar xz -C /opt && \
    mv /opt/noVNC-1.6.0 /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Install websockify
RUN pip3 install --no-cache-dir websockify

# Install Floorp
RUN wget -O /tmp/floorp.deb \
    https://github.com/Floorp-Projects/Floorp/releases/download/v12.18.1/floorp-12.18.1.deb && \
    apt-get update && \
    apt-get install -y /tmp/floorp.deb && \
    rm -f /tmp/floorp.deb && \
    rm -rf /var/lib/apt/lists/*

# Display
ENV DISPLAY=:1
ENV RESOLUTION=1280x800x24

EXPOSE 10000

# Start desktop + Floorp + VNC + noVNC
CMD Xvfb :1 -screen 0 $RESOLUTION -ac +extension GLX +render -noreset & \
    sleep 2 && \
    openbox-session & \
    sleep 2 && \
    floorp --no-remote --disable-gpu & \
    sleep 3 && \
    x11vnc -display :1 -nopw -listen localhost -forever -shared & \
    sleep 2 && \
    /usr/local/bin/websockify --web=/opt/novnc 0.0.0.0:${PORT:-10000} localhost:5900
