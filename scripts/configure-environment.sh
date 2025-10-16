#!/bin/bash -e

get_etc_environment_variable() {
    local variable_name=$1

    # remove `variable_name=` and possible quotes from the line
    grep "^${variable_name}=" /etc/environment | sed -E "s%^${variable_name}=\"?([^\"]+)\"?.*$%\1%"
}

add_etc_environment_variable() {
    local variable_name=$1
    local variable_value=$2

    echo "${variable_name}=${variable_value}" | sudo tee -a /etc/environment
}

replace_etc_environment_variable() {
    local variable_name=$1
    local variable_value=$2

    # modify /etc/environemnt in place by replacing a string that begins with variable_name
    sudo sed -i -e "s%^${variable_name}=.*$%${variable_name}=${variable_value}%" /etc/environment
}

set_etc_environment_variable() {
    local variable_name=$1
    local variable_value=$2

    if grep "^${variable_name}=" /etc/environment > /dev/null; then
        replace_etc_environment_variable $variable_name $variable_value
    else
        add_etc_environment_variable $variable_name $variable_value
    fi
}

# Prepare directory and env variable for toolcache
AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
mkdir $AGENT_TOOLSDIRECTORY
set_etc_environment_variable "AGENT_TOOLSDIRECTORY" "${AGENT_TOOLSDIRECTORY}"
set_etc_environment_variable "RUNNER_TOOL_CACHE" "${AGENT_TOOLSDIRECTORY}"
chmod -R 777 $AGENT_TOOLSDIRECTORY