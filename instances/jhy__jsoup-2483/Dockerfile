ARG SOURCE_IMAGE=claudedata-swe-env:jhy__jsoup-2483-044b89998433
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="jhy__jsoup-2483" \
      io.claudedata.source-image-id="sha256:0c6db7627bc130ef136dcbd200d706a0ea4432847c818c80fa32b1e1234caff0"

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
