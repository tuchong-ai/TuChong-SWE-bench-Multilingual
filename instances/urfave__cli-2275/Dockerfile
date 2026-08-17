ARG SOURCE_IMAGE=claudedata-swe-env:urfave__cli-2275-f3a80114de14
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="urfave__cli-2275" \
      io.claudedata.source-image-id="sha256:0a47cf68d60602693bd649820c8680ef20f447412887ed2ad761e7471b548e8e"

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
