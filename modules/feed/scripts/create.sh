#!/bin/bash

# Source common functions
source common.sh

# Define constants
max_retries=100
retry_delay_in_seconds=10

# Define variables for feed creation
retries=1
url="https://feeds.dev.azure.com/${azdo_org}/${project_name}/_apis/packaging/feeds?api-version=7.0"
data="{\"name\": \"${feed_name}\"}"

# Try to create the feed until the feed name is not reserved or until the maximum retry number is reached
while check_response_code --reversed && [[ "${retries}" -le "${max_retries}" ]]; do
	call_rest_api --request POST --token "${azdo_pat}" --url "${url}" --data "${data}"
    if check_response_code --common-message "Feed ${feed_name} " --success-message "created successfully" --error-message "is reserved, retrying in ${retry_delay_in_seconds} seconds (${retries}/${max_retries})"; then
		get_value_from_response --name "feed_id" --filter ".id"
    else
        retries=$((retries+1))
        sleep $retry_delay_in_seconds
    fi
done
check_response_code --error-message "${feed_name} could not be created!" --exit-on-error

# Get the service account for pipeline runs
url="https://vssps.dev.azure.com/${azdo_org}/_apis/identities?searchFilter=General&filterValue=${project_name}%20Build%20Service%20%28${azdo_org}%29&api-version=6.0"
call_rest_api --request GET --token "${azdo_pat}" --url "${url}"
check_response_code --error-message "Project Collection Build Service (${azdo_org}) user could not be found!" --exit-on-error
get_value_from_response --name "descriptor" --filter ".value[].descriptor"

# Add the service account to the feed
url="https://feeds.dev.azure.com/${azdo_org}/${project_name}/_apis/packaging/Feeds/${feed_id}/permissions?api-version=7.0"
data="[{\"role\": \"contributor\", \"identityDescriptor\": \"${descriptor}\", \"isInheritedRole\": false}]"
call_rest_api --request PATCH --token "${azdo_pat}" --url "${url}" --data "${data}" 
check_response_code --common-message "${project_name} Build Service (${azdo_org}) " --success-message "added as contributor to the feed" --error-message "could not be added as contributor to the feed!" --exit-on-error