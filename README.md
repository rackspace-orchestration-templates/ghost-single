[![Circle CI](https://circleci.com/gh/rackspace-orchestration-templates/ghost-single/tree/master.png?style=shield)](https://circleci.com/gh/rackspace-orchestration-templates/ghost-single)
Description
===========

This is a template for deploying [Ghost](https://ghost.org/) on a single Linux
server. This template is leveraging
[chef-solo](http://docs.opscode.com/chef_solo.html) to setup the server.

Requirements
============
* A Heat provider that supports the following:
  * OS::Nova::KeyPair
  * Rackspace::Cloud::Server
  * OS::Heat::RandomString
  * OS::Heat::ChefSolo
* An OpenStack username, password, and tenant id.
* [python-heatclient](https://github.com/openstack/python-heatclient)
`>= v0.2.8`:

```bash
pip install python-heatclient
```

We recommend installing the client within a [Python virtual
environment](http://www.virtualenv.org/).

Example Usage
=============
Here is an example of how to deploy this template using the
[python-heatclient](https://github.com/openstack/python-heatclient):

```
heat --os-username <OS-USERNAME> --os-password <OS-PASSWORD> --os-tenant-id \
  <TENANT-ID> --os-auth-url https://identity.api.rackspacecloud.com/v2.0/ \
  stack-create Ghost-Stack -f ghost-single.yaml -P flavor="4 GB Performance"
```

* For UK customers, use `https://lon.identity.api.rackspacecloud.com/v2.0/` as
the `--os-auth-url`.

Optionally, set environmental variables to avoid needing to provide these
values every time a call is made:

```
export OS_USERNAME=<USERNAME>
export OS_PASSWORD=<PASSWORD>
export OS_TENANT_ID=<TENANT-ID>
export OS_AUTH_URL=<AUTH-URL>
```

Parameters
==========
Parameters can be replaced with your own values when standing up a stack. Use
the `-P` flag to specify a custom parameter.

* `username`: Login name for both the database and system user (Default: ghost)
* `domain`: Domain to be used with Ghost site (Default: ghost.example.com)
* `database_name`: Ghost database name (Default: ghost)
* `version`: Ghost version to be used (Default: latest)
* `image`: Server image used for all servers that are created as a part of this
  deployment (Default: Ubuntu 12.04 LTS (Precise Pangolin))
* `flavor`: Rackspace Cloud Server flavor to use. The size is based on the
  amount of RAM for the provisioned server. (Default: 4 GB Performance)
* `chef_version`: Version of chef client to use (Default: 11.12.8)
* `kitchen`: URL for a git repo containing required cookbooks (Default:
  https://github.com/rackspace-orchestration-templates/ghost-single)

Outputs
=======
Once a stack comes online, use `heat output-list` to see all available outputs.
Use `heat output-show <OUTPUT NAME>` to get the value fo a specific output.

* `private_key`: SSH private that can be used to login as root to the server.
* `server_ip`: Public IP address of the cloud server.
* `ghost_url`: URL to access Ghost for the first time.
* `ghost_user`: The non-privileged user that has sudo access.
* `ghost_user_password`: Password to use with `ghost_user` when logging in via
  SSH

For multi-line values, the response will come in an escaped form. To get rid of
the escapes, use `echo -e '<STRING>' > file.txt`. For vim users, a substitution
can be done within a file using `%s/\\n/\r/g`.

Stack Details
=============
#### Accessing Your Deployment

If you provided a domain name that is associated with your Rackspace Cloud
account and chose to create DNS records, you should be able to navigate to
the provided domain name in your browser. If DNS has not been configured yet,
please refer to this
[documentation](http://www.rackspace.com/knowledge_center/article/how-do-i-modify-my-hosts-file)
on how to setup your Hosts file to allow your browser to access your
Deployment via domain name.

To SSH into your server as "root", please use the SSH private key provided in
the deployment's secrets. Please refer to our Knowledge Center for
instructions on how to use SSH keys on
[Linux/Mac](http://www.rackspace.com/knowledge_center/article/logging-in-with-a-ssh-private-key-on-linuxmac)
or
[Windows](http://www.rackspace.com/knowledge_center/article/logging-in-with-a-ssh-private-key-on-windows).

You may also SSH into the server as the "ghost" user with the "ghost User
Password" provided in the deployment's secrets. Once logged in as this user,
you can use "sudo" to perform commands as root. The following commands will
assume you are using the "ghost" user and will use "sudo". If you prefer to
use "root", please drop the "sudo" from the examples.

Once you have SSH'd into your server, you will find Ghost installed in
/var/www/vhosts/<domain_name>. There is an
[Upstart](http://upstart.ubuntu.com/) job configured in
"/etc/init/ghost.conf" to control the Ghost service. You can start or stop
the Ghost service by running "sudo start ghost" or "sudo stop ghost". You can
find logs for the Ghost service in "/var/log/upstart/ghost.log". Ghost runs
on port 2368; however, Nginx is configured to listen on port 80 and 443 (if
SSL was configured) and pass requests to 2368. You can find the Nginx
configuration for Ghost in "/etc/nginx/sites-available/ghost.conf".

#### Getting Started

Ghost is a new blogging platform dedicated to providing a simple, easy to use
approach to blogging. Ghost allows you to write and publish your own blog,
giving you the tools to make it easy and even fun to do. It's simple,
elegant, and designed so that you can spend less time messing with making
your blog work - and more time blogging.

The first step with your new blog is to navigate to `/ghost/signup` where you
will create the your user. Ghost currently only supports one user at this
time. After filling out this info, you will be redirected to the admin panel
where you can start customizing your blog and adding new posts. To access the
admin panel again, navigate to `/ghost`.

For more information on using Ghost please check out Ghost's [usage
forums](https://ghost.org/forum/using-ghost/).

#### Plugins

Ghost is new and is still in heavy development. However, there are already
some plugins and themes to help customize your experience. Checkout the Ghost
[Marketplace](http://marketplace.ghost.org/) for links. Users coming from
WordPress may also be interested in this [WordPress
plugin](http://wordpress.org/plugins/ghost/) to help migrate data from
WordPress to Ghost.

Contributing
============
There are substantial changes still happening within the [OpenStack
Heat](https://wiki.openstack.org/wiki/Heat) project. Template contribution
guidelines will be drafted in the near future.

License
=======
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
