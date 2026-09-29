FROM debian:bookworm-slim

# Install system dependencies, VNC, noVNC, and Openbox
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    xvfb \
    x11vnc \
    openbox \
    python3 \
    python3-pip \
    git \
    &> /dev/null

# Install noVNC and websockify
RUN git clone https://github.com /opt/novnc && \
    git clone https://github.com /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Install Floorp Browser via official PPA instructions
RUN curl -fsSL https://floorp.app | gpg --dearmor -o /usr/share/keyrings/Floorp.gpg && \
    curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list "https://floorp.app" && \
    apt-get update && apt-get install -y floorp

# Set environment variables for the display server
ENV DISPLAY=:1
ENV RESOLUTION=1280x800x24

EXPOSE 10000

# Start script to run everything together
CMD Xvfb :1 -screen 0 $RESOLUTION & \
    sleep 2 && \
    openbox-session & \
    sleep 1 && \
    floorp --no-remote & \
    x11vnc -display :1 -nopw -listen localhost -forever -shared & \
    sleep 2 && \
    /opt/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 0.0.0.0:10000
