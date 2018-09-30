FROM clickable/ubuntu-sdk:16.04-amd64

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    pyotherside \
    # testing QT with python
    xvfb \
    python3-autopilot \
    # DEACTIVATED as or oxide error 
    # ubuntu-ui-toolkit-autopilot \
    python-xlib \
    # apps
    # # DEACTIVATED as or oxide error 
    # webbrowser-app \
    gallery-app
RUN apt-get clean

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d/ && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer
WORKDIR /home/developer/ubports_build
CMD bash
