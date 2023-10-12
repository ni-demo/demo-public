# Define usage function for call_rest_api
call_rest_api_usage(){
	echo ""
	echo "Usage:"
	echo " $0 [options]"
	echo ""
	echo "Execute a REST API call using call. Its functionalities are optimized for the feed AzDo API."
	echo ""
	echo "Options:"
	echo " -d, --data <data>          the data to send as the body of the request"
	echo " -r, --request <request>    the type of the request such as GET, POST, DELETE, etc"
	echo " -t, --token <token>        the personal access token to authenticate the request with"
	echo " -u, --url <url>            the URL to which the request should be sent"
	echo ""
	echo " -h, --help                 display this help"
	echo ""
	echo "Please note that the request, the token and the url are required options."
	echo ""
}

# Define call_rest_api function
call_rest_api(){
	# Read script options
	local options=$(getopt --options "r:u:t:d:h" --long "request:,url:,token:,data:,help" -- "$@")
	if [[ $? -ne 0 ]]; then
		call_rest_api_usage
		return 1
	fi

	# Parse function options
	eval set -- "${options}"
	while true; do
		case "$1" in
			-r | --request) local request="$2"; shift 2;;
			-u | --url) local url="$2"; shift 2;;
			-t | --token) local token="$2"; shift 2;;
			-d | --data) local data="$2"; shift 2;;
			-h | --help) call_rest_api_usage; return 0;;
			--) shift 1; break;;
			*) break;;
		esac
	done
	
	# Validate required options
	local required_options_provided="true"
	if [[ -z "${request}" ]]; then
	  echo "Request is required!"
	  required_options_provided="false"
	fi
	if [[ -z "${url}" ]]; then
	  echo "Url is required!"
	  required_options_provided="false"
	fi
	if [[ -z "${token}" ]]; then
	  echo "Token is required!"
	  required_options_provided="false"
	fi
	if [[ "${required_options_provided}" = "false" ]]; then
	  return 1
	fi
	
	# Execute the curl call
	if [[ -n "${data}" ]]; then
		curl --silent --request $request $url \
			 --header "Content-Type: application/json" \
			 --user ":${token}" \
			 --data "$data" \
			 --output response.json \
			 --write-out %{http_code} \
			 > response.code 2> error.txt
	else
		curl --silent --request $request $url \
			 --user ":${token}" \
			 --output response.json \
			 --write-out %{http_code} \
			 > response.code 2> error.txt
	fi
	
	# Read the return values
	response=$(cat response.json | jq '.')
	response_code=$(cat response.code)
	error_message=$(cat error.txt)

	# Cleanup
	rm -f response.json
	rm -f response.code
	rm -f error.txt
	
	# Return success
	return 0
}

# Define usage function for check_response_code
check_response_code_usage(){
	echo ""
	echo "Usage:"
	echo " $0 [options]"
	echo ""
	echo "Check if the response code of a REST API call is within the 200-299 interval and print messages accordingly."
	echo "It can also stop the script's execution if set up that way."
	echo "Should be called after the call_rest_api function as this function relies on its return values."
	echo ""
	echo "Options:"
	echo " -c, --common-message <common-message>      the message to print both before success and error messages"
	echo " -e, --error-message <error-message>        the message to print if the response code is not within the 200-299 interval"
	echo " -s, --success-message <success-message>    the message to print if the response code is within the 200-299 interval"
	echo " -r, --reversed                             flag to indicate whether the 200-299 interval should be counted as error and everthing else as success"
	echo " -x, --exit-on-success                      flag to indicate to stop the script if the response code is within the 200-299 interval"
	echo " -y, --exit-on-error                        flag to indicate to stop the script if the response code is not within the 200-299 interval"
	echo ""
	echo " -h, --help                                 display this help"
	echo ""
}

# Define check_response_code function
check_response_code(){
	# Read script options
	local options=$(getopt --options "c:s:e:rxyh" --long "common-message:,success-message:,error-message:,reversed,exit-on-success,exit-on-error,help" -- "$@")
	if [[ $? -ne 0 ]]; then
		check_response_code_usage
		return 1
	fi

	# Parse function options
	eval set -- "${options}"
	while true; do
		case "$1" in
			-c | --common-message) local common_message="$2"; shift 2;;
			-s | --success-message) local success_message="$2"; shift 2;;
			-e | --error-message) local other_message="$2"; shift 2;; # named as other_message to avoid conflict with the return value of call_rest_api
			-r | --reversed) local reversed="true"; shift 1;;
			-x | --exit-on-success) local exit_on_success="true"; shift 1;;
			-y | --exit-on-error) local exit_on_error="true"; shift 1;;
			-h | --help) check_response_code_usage; return 0;;
			--) shift 1; break;;
			*) break;;
		esac
	done

	# Check the response code
	if [[ -z "${reversed}" ]]; then
		if [[ "${response_code}" =~ ^2[0-9]{2}$ ]]; then
			check_result="success"
		else
			check_result="error"
		fi
	else
		if [[ "${response_code}" =~ ^2[0-9]{2}$ ]]; then
			check_result="error"
		else
			check_result="success"
		fi
	fi

	# Print messages and handle return values
	if [[ "${check_result}" == "success" ]]; then
		if [[ -n "${common_message}${success_message}" ]]; then 
			echo "${common_message}${success_message}"
		fi
		if [[ -n "${exit_on_success}" ]]; then 
			exit 0
		else
			return_value=0
		fi	
	else
		if [[ -n "${common_message}${other_message}" ]]; then 
			echo "${common_message}${other_message}"
		fi
		if [[ -n "${exit_on_error}" ]]; then 
			echo "Response code: ${response_code}"
			echo "Error message: ${error_message}"
			exit 1
		else
			return_value=1
		fi		
	fi
	
	# Return success or error
	return $return_value
}

# Define usage function for get_value_from_response
get_value_from_response_usage(){
	echo ""
	echo "Usage:"
	echo " $0 [options]"
	echo ""
	echo "Filters the response of a REST API call and stores the result in a variable."
	echo "Should be called after the call_rest_api function as this function relies on its return values."
	echo ""
	echo "Options:"
	echo " -n, --name <name>        the name of the variable in which the value should be stored"
	echo " -f, --filter <filter>    the jq filter to be used to find the value"
	echo " -p, --print              a flag to determine whether the value should be printed"
	echo ""
	echo " -h, --help               display this help"
	echo ""
}

# Define get_value_from_response function
get_value_from_response(){
	# Read script options
	local options=$(getopt --options "n:f:ph" --long "name:,filter:,print,help" -- "$@")
	if [[ $? -ne 0 ]]; then
		get_value_from_response_usage
		return 1
	fi

	# Parse function options
	eval set -- "${options}"
	while true; do
		case "$1" in
			-n | --name) local name="$2"; shift 2;;
			-f | --filter) local filter="$2"; shift 2;;
			-p | --print) local print="true"; shift 1;;
			-h | --help) get_value_from_response_usage; return 0;;
			--) shift 1; break;;
			*) break;;
		esac
	done

	# Get value and store it in a variable
	value=$(echo "${response}" | jq --raw-output "${filter}")
	eval "${name}=\"${value}\""
	if [[ -n "${print}" ]]; then
		echo "${name}: ${!name}"
	fi
	
	# Return success
	return 0
}