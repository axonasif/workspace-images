ARG base
FROM ${base}

USER gitpod

# Dazzle does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_REBUILD=5

ENV PATH=$HOME/.cargo/bin:$PATH

RUN curl -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path --default-toolchain stable \
        -c rls rust-analysis rust-src rustfmt clippy \
    && for cmp in rustup cargo; do rustup completions bash "$cmp" > "$HOME/.local/share/bash-completion/completions/$cmp"; done \
    && cargo install cargo-watch cargo-edit cargo-workspaces \
    && rm -rf "$HOME/.cargo/registry" # This registry cache is now useless as we change the CARGO_HOME path to `/workspace`

COPY --chown=gitpod:gitpod rust_bashrc.sh $HOME/.bashrc.d/80-rust
COPY --chown=gitpod:gitpod rust_runonce.sh $HOME/.runonce/80-rust
