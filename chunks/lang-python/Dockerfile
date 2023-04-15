ARG base
FROM ${base}

ARG PYTHON_VERSION

USER gitpod
# Dazzle does not rebuild a layer until one of its lines are changed. Increase this counter to rebuild this layer.
ENV TRIGGER_REBUILD=1

ENV RUNTIME_VIRTUAL_ENV="/workspace/.python_venv"
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PIPENV_VENV_IN_PROJECT=true
ENV PIP_CACHE_DIR="${RUNTIME_VIRTUAL_ENV}/pip_cache"
ENV PYTHONUSERBASE="${RUNTIME_VIRTUAL_ENV}/python_userbase"
ENV PATH="${RUNTIME_VIRTUAL_ENV}/bin:${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PYTHONUSERBASE}/bin:$PATH"
# Poetry customizations
ENV POETRY_CACHE_DIR="${RUNTIME_VIRTUAL_ENV}/poetry_cache"

# configure the default intepreter for PyCharm
ENV PYCHARM_PYTHON_PATH="${RUNTIME_VIRTUAL_ENV}/bin/python"

RUN sudo install-packages \
	# Install python compiling dependencies for pyenv
	python3-pip make build-essential libssl-dev zlib1g-dev \
	libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
	libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
	# Install PYENV
	&& git clone https://github.com/pyenv/pyenv.git ~/.pyenv \
	&& git -C ~/.pyenv checkout 20189ff06f76fb1eec7b149ad6f86134057c809c \
	&& pyenv install ${PYTHON_VERSION} \
	&& pyenv global ${PYTHON_VERSION} \
	# Install additional python packages
	&& python3 -m pip install --no-cache-dir --upgrade pip \
	&& pip install --no-cache-dir --upgrade \
	setuptools wheel virtualenv pipenv pylint rope flake8 \
	mypy autopep8 pep8 pylama pydocstyle bandit notebook \
	twine
# Install poetry
RUN if echo $PYTHON_VERSION | grep -q "3.6.*"; then \
		curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.1.15 python; \
    else \
		curl -sSL https://install.python-poetry.org | python; \
	fi
RUN sudo rm -rf /tmp/*

COPY --chown=gitpod:gitpod python_bashrc.sh $HOME/.bashrc.d/60-python
COPY --chown=gitpod:gitpod python_runonce.sh $HOME/.runonce/0-python
