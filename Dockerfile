FROM alpine:3.16

LABEL maintainer="DRH <DRH@gmail.com>"

RUN apk add --no-cache sudo git wget bash python3 tigervnc \  
    xfce4 xfce4-goodies xfce4-terminal faenza-icon-theme \
    #cmake xfce4-screensaver 
    # pulseaudio xfce4-pulseaudio-plugin pavucontrol pulseaudio-alsa alsa-plugins-pulse alsa-lib-dev nodejs npm

# RUN build-base
    # don't create during Alpine-setup!
    && adduser -h /home/ffnpa -s /bin/bash -S -D ffnpa && echo -e "ffnpa\nffnpa" | passwd ffnpa \
    && echo 'ffnpa ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && git clone https://github.com/novnc/noVNC /opt/noVNC \
    && git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify
    # && wget https://raw.githubusercontent.com/davidhaynz/Alpine_xfce4_noVNC/dev/script.js -O /opt/noVNC/script.js \
    # && wget https://raw.githubusercontent.com/davidhaynz/Alpine_xfce4_noVNC/dev/audify.js -O /opt/noVNC/audify.js \
    # && wget https://raw.githubusercontent.com/davidhaynz/Alpine_xfce4_noVNC/dev/vnc.html -O /opt/noVNC/vnc.html \
    # && wget https://raw.githubusercontent.com/davidhaynz/Alpine_xfce4_noVNC/dev/pcm-player.js -O /opt/noVNC/pcm-player.js

# RUN npm install --prefix /opt/noVNC ws

# RUN npm install --prefix /opt/noVNC audify

USER ffnpa
WORKDIR /home/ffnpa

RUN mkdir -p /home/ffnpa/.vnc \
    # && echo -e "-Securitytypes=none" > /home/ffnpa/.vnc/config \
    && echo -e "#!/bin/bash\nstartxfce4 &" > /home/ffnpa/.vnc/xstartup \
    && echo -e "ffnpa\nffnpa\nn\n" | vncpasswd


RUN echo '\
#!/bin/bash \
/usr/bin/vncserver :99 2>&1 | sed  "s/^/[Xtigervnc ] /" & \
sleep 1 & \
/usr/bin/pulseaudio 2>&1 | sed  "s/^/[pulseaudio] /" & \
sleep 1 & \
/usr/bin/node /opt/noVNC/audify.js 2>&1 | sed "s/^/[audify    ] /" & \
/opt/noVNC/utils/novnc_proxy --vnc localhost:5999 2>&1 | sed "s/^/[noVNC     ] /"'\
>/entry.sh

USER ffnpa

ENTRYPOINT [ "/bin/bash", "/entry.sh" ]
