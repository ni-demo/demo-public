#!/bin/bash

# Source common functions
source common.sh

# Get the feed's id
url="https://feeds.dev.azure.com/${azdo_org}/${project_name}/_apis/packaging/feeds?api-version=7.0"
call_rest_api --request GET --token "${azdo_pat}" --url "${url}"
get_value_from_response --name "feed_id" --filter ".value[] | select(.name == \"${feed_name}\").id"
if [[ -z "${feed_id}" ]]; then
    echo "Feed ${feed_name} was not found, nothing to delete!"
    exit 0
fi

# Delete the feed
url="https://feeds.dev.azure.com/${azdo_org}/${project_name}/_apis/packaging/feeds/${feed_id}?api-version=7.0"
call_rest_api --request DELETE --token "${azdo_pat}" --url "${url}"
check_response_code --common-message "Feed ${feed_name} " --success-message "deleted successfully" --error-message "could not be deleted!" --exit-on-error

# Permanently delete the feed
url="https://feeds.dev.azure.com/${azdo_org}/${project_name}/_apis/packaging/feedrecyclebin/${feed_id}?api-version=7.0"
call_rest_api --request DELETE --token "${azdo_pat}" --url "${url}"
check_response_code --common-message "Feed ${feed_name} " --success-message "removed permanently" --error-message "could not be removed permanently!" --exit-on-error