FROM rustdesk/rustdesk-server-pro:1.7.3

# Remove /root so we can replace it with a mount point
RUN rm -rf /root && mkdir -p /root

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
