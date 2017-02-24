#
# Cookbook::  chef-client
# Attributes:: updater
#
# Copyright:: 2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# stable or current channel
default['chef_client']['updater']['channel'] = 'stable'

# prevent a newer client "updating" to an older client
default['chef_client']['updater']['prevent_downgrade'] = true

# the version to install (ex: '12.12.13') or 'latest'
default['chef_client']['updater']['version'] = 'latest'

# kill the client post install or exec the client post install for non-service based installs
default['chef_client']['updater']['post_install_action'] = 'kill'
