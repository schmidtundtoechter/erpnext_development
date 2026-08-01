# Simplified Dockerfile for Frappe Bench initialization
FROM python:3.11-slim-bookworm

# Basic variables
ARG NODE_VERSION=20.19.2
ENV NVM_DIR=/home/frappe/.nvm
ENV PATH=${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}

# Install docker & gpg
ARG TARGETARCH
RUN echo "Install docker for arch=${TARGETARCH}" && apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    vim \
    git \
    iputils-ping \
    software-properties-common \
    gnupg-agent && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=${TARGETARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user
RUN useradd -ms /bin/bash frappe

# Install system packages
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl cron file jq \
    git \
    sudo \
    rsync \
    # PostgreSQL Client
    postgresql-client \
    libpq-dev \
    # MariaDB Client and Development Libraries
    mariadb-client \
    libmariadb-dev \
    libmariadb-dev-compat \
    # Build tools for Python packages
    gcc \
    g++ \
    build-essential \
    # Additional required packages
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf (mit gepatchtem Qt) für die PDF-Erzeugung von Druckformaten.
# Das Distro-Paket ist ohne Patch und benötigt einen X-Server; das offizielle
# wkhtmltox-Paket läuft headless.
RUN WKHTML_ARCH="${TARGETARCH:-$(dpkg --print-architecture)}" \
    && apt-get update \
    && curl -fsSL -o /tmp/wkhtmltox.deb \
       "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_${WKHTML_ARCH}.deb" \
    && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
    && rm -rf /tmp/wkhtmltox.deb /var/lib/apt/lists/*

# Install Node.js
RUN mkdir -p ${NVM_DIR} \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
    && . ${NVM_DIR}/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm use v${NODE_VERSION} \
    && npm install -g yarn \
    && nvm alias default v${NODE_VERSION} \
    && rm -rf ${NVM_DIR}/.cache \
    && chown -R frappe:frappe ${NVM_DIR}

# Install frappe-bench
RUN pip3 install frappe-bench

# Configure sudo without password for frappe user
RUN echo "frappe ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/frappe

# Create workspace directory (as root)
RUN mkdir -p /workspace/development && chown -R frappe:frappe /workspace

# Install necessary packages
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
  sudo dos2unix rsync cron wget ssh build-essential
RUN rm -rf /var/lib/apt/lists/*

# Add scripts from init directory
COPY init/installApp.sh /home/frappe/installApp.sh
COPY init/fix-git-refs.sh /home/frappe/fix-git-refs.sh
COPY init/initBench.sh /home/frappe/initBench.sh
COPY init/initERPNextMCP.sh /home/frappe/initERPNextMCP.sh
COPY init/aliases.sh /home/frappe/aliases.sh
RUN dos2unix /home/frappe/*.sh
RUN chown frappe:frappe /home/frappe/*.sh && chmod +x /home/frappe/*.sh

# Setup Node.js environment for frappe user
USER frappe
RUN echo 'export NVM_DIR="/home/frappe/.nvm"' >> /home/frappe/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/frappe/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/frappe/.bashrc

# Add aliases
RUN echo "alias ll='ls -al'" >> ~/.bashrc
RUN echo "source /home/frappe/aliases.sh" >> ~/.bashrc

# Set workspace directory
WORKDIR /workspace/development

# Default command
CMD ["/bin/bash"]