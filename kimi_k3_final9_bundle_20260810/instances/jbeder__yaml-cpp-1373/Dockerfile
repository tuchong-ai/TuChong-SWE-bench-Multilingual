ARG SOURCE_IMAGE=claudedata-swe-env:jbeder__yaml-cpp-1373-af82e581710f
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="jbeder__yaml-cpp-1373" \
      io.claudedata.source-image-id="sha256:376d6da4b3a2128a2d1d6bed663fd00336b9514259cb8953311e18ce3cdc7724"

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
