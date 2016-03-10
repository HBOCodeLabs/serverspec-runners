# serverspec-runners

Runner scripts for kitchen-verifier-serverspec.

These files do enhanced functionality for serverspec testing in test kitchen when you set in the kitchen.yaml file
```
runner_url: https://raw.githubusercontent.com /neillturner/serverspec-runners/master/ansiblespec_runner.rb
require_runner: true
```
By default test kitchen will always download and use the latest version of this install file.

This script will install the puppet on a server. It defaults to puppet 3.x

WARNING: AS SOON AS YOU MERGE CODE HERE IT IS INSTANTLY AVAILABLE TO EVERYONE USING THE RUNNER FROM KITCHEN-VERIFIER-SERVERSPEC:

To get a previous version or lock the install script to a particular version update your kitchen.yaml file to:
```
runner_url: https://raw.githubusercontent.com/neillturner/serverspec-runners/ab2fa5771b6ef357786d7ff57d83fc8c97c22fed/ansiblespec_runner.rb
require_runner: true
```
where ab2fa5771b6ef357786d7ff57d83fc8c97c22fed is the commit sha of the code.


License
---
```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```