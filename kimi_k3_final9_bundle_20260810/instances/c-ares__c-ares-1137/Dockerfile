ARG SOURCE_IMAGE=claudedata-swe-env:c-ares__c-ares-1137-c010d38c2983
FROM ${SOURCE_IMAGE}

LABEL io.claudedata.environment-recipe="swe-environment-recipe-v1" \
      io.claudedata.instance-id="c-ares__c-ares-1137" \
      io.claudedata.source-image-id="sha256:1701767eb9671164231fb2bafbf9351ccc2630f32b841bb6078af58f16b1f498"

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
