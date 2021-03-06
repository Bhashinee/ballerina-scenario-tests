#!/bin/bash
# Copyright (c) 2019, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

readonly test_clientHandleErrors_parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
readonly test_clientHandleErrors_grand_parent_path=$(dirname ${test_clientHandleErrors_parent_path})
readonly test_clientHandleErrors_great_grand_parent_path=$(dirname ${test_clientHandleErrors_grand_parent_path})
readonly test_clientHandleErrors_great_great_grand_parent_path=$(dirname ${test_clientHandleErrors_great_grand_parent_path})

. ${test_clientHandleErrors_great_grand_parent_path}/common/usage.sh
. ${test_clientHandleErrors_great_grand_parent_path}/setup/setup_test_env.sh

run_provided_test() {
    local test_group_to_run=${deployment_config["TestGroup"]}

    if [ "${test_group_to_run}" = "clientHandleErrors" ]; then
        . ${test_clientHandleErrors_parent_path}/test.sh
    fi
}

run_provided_test
