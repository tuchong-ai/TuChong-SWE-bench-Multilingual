ARG SOURCE_IMAGE=claudedata-swe-env:jhy__jsoup-2476-0d375b707c9d
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="jhy__jsoup-2476" \
      io.claudedata.source-image-id="sha256:325198692767420ee94fc641e65075c26b956c13ea4c92fac6259756bdca0af6"

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
