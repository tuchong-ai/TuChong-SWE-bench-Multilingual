ARG SOURCE_IMAGE=claudedata-swe-env:jarro2783__cxxopts-314-6bb2641d651f
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="jarro2783__cxxopts-314" \
      io.claudedata.source-image-id="sha256:666848cd5b662f27c11b59728742508b4e85f4802bce00c44156d1c5ee0174e6"

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
