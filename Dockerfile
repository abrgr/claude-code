FROM gitpod/workspace-full:latest

USER root
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      jq less tree && \
    rm -rf /var/lib/apt/lists/*

# Install Claude CLI native binary to /usr/local/bin
ARG CLAUDE_VERSION
RUN curl -fsSL https://claude.ai/install.sh | bash -s "${CLAUDE_VERSION}" && \
    mv ~/.local/bin/claude /usr/local/bin/claude && \
    chmod 755 /usr/local/bin/claude

RUN usermod -u 1001 gitpod \
  && groupmod -g 1001 gitpod \
  && chown -R 1001:1001 /home/gitpod

RUN chown -R 1001:1001 /workspace

USER gitpod

# Default to interactive shell so the alias can pass commands/args
CMD ["bash"]
