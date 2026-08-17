ARG SOURCE_IMAGE=claudedata-swe-env:gin-gonic__gin-4622-93e989f7ae97
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="gin-gonic__gin-4622" \
      io.claudedata.source-image-id="sha256:60d48a859285d0a537e7ef6a322046d221a53a82b1ca850260653c0c5d908122"

USER root
RUN rm -rf /testbed /tmp/.claudedata-venv \
    && install -d -o agent -g agent /testbed \
    && install -d -o agent -g agent /opt/claudedata
COPY --chmod=0755 setup_repo.sh setup_env.sh /opt/claudedata/

USER agent
WORKDIR /testbed
RUN /opt/claudedata/setup_repo.sh \
    && /opt/claudedata/setup_env.sh

CMD ["sleep", "infinity"]
