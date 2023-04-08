ARG base
FROM ${base}

USER gitpod
# Dazzle does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_REBUILD=1

# Install .NET SDK (Current channel)
# Source: https://docs.microsoft.com/dotnet/core/install/linux-scripted-manual#scripted-install
RUN mkdir -p /home/gitpod/dotnet && curl -fsSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version 7.0.100 --install-dir /home/gitpod/dotnet
ENV DOTNET_ROOT=/home/gitpod/dotnet
ENV PATH=/home/gitpod/dotnet:$PATH

# TODO(toru): Remove this hack when the kernel bug is resolved.
#             ref. https://github.com/gitpod-io/gitpod/issues/8901
COPY --chown=gitpod:gitpod dotnet_runonce.sh $HOME/.runonce/110-dotnet
