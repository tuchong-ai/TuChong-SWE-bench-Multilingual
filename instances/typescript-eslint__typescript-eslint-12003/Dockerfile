ARG SOURCE_IMAGE=claudedata-swe-env:typescript-eslint__typescript-eslint-12003-1fad54c94934
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="typescript-eslint__typescript-eslint-12003" \
      io.claudedata.source-image-id="sha256:d0e8be0474d093c7954afe0d48b22343ae0b1bfe77601f5540b0b7eb9d737991"

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
