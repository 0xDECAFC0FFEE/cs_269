FROM conda/miniconda3
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install apt-utils build-essential wget tmux nmap vim htop curl git
RUN conda update -n base -c defaults conda
# install pytorch cpu
RUN conda install pytorch torchvision cpuonly -c pytorch

# install zsh
RUN sh -c "$(wget -O- https://raw.githubusercontent.com/deluan/zsh-in-docker/master/zsh-in-docker.sh)"
RUN chsh -s `which zsh`

# set up ssh
RUN apt-get -y install openssh-server
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN passwd -d `whoami`
RUN echo "Port 7722\nPermitEmptyPasswords yes\nX11Forwarding yes\nPrintMotd no\nAcceptEnv LANG LC_*\nSubsystem       sftp    /usr/lib/openssh/sftp-server\nPasswordAuthentication yes\nPermitRootLogin yes" > /etc/ssh/sshd_config
EXPOSE 7722

# install lucas's env
ADD https://api.github.com/repos/0xDECAFC0FFEE/.setup/git/refs/ version.json
RUN git clone https://github.com/0xDECAFC0FFEE/.setup.git /root/.setup
RUN conda install --file /root/.setup/requirements.txt
RUN python3 /root/.setup/setup.py --disable-ssh

# skipping jupyter install
# RUN conda install jupyterlab -y
# RUN conda install -c conda-forge ipywidgets -y
# RUN conda upgrade -c conda-forge jupyterlab -y
# RUN conda install nodejs -y
# RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager -y

# installing project requirements.txt
RUN conda config --append channels conda-forge
COPY requirements_slim.txt /root/requirements.txt
RUN conda install --file /root/requirements.txt

# CMD ./start_jupyter_tensorboard_ssh.sh && `which zsh`
CMD service ssh restart && `which zsh`
