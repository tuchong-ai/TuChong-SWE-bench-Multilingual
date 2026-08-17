ARG SOURCE_IMAGE=claudedata-swe-env:lvgl__lvgl-10308-573da684b069
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="lvgl__lvgl-10308" \
      io.claudedata.source-image-id="sha256:db7712d53e0615f8b3769a92e1b68b18e4b41e026d22a128713497a458dd5e70"

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
