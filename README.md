osl-imap Cookbook
=================
A wrapper cookbook providing IMAP capabilities for the Open Source Lab.

Requirements
------------

#### Platforms
- CentOS 7
- AlmaLinux 8

#### Cookbooks
- [certificate](https://supermarket.chef.io/cookbooks/certificate)
- [dovecot](https://supermarket.chef.io/cookbooks/dovecot)
- [firewall](https://github.com/osuosl-cookbooks/firewall)

Attributes
----------
#### osl-imap::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['osl-imap']['auth_sql']['data_bag']</tt></td>
    <td>String</td>
    <td>Name of databag containing SQL credentials</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['osl-imap']['auth_sql']['data_bag_item']</tt></td>
    <td>String</td>
    <td>Name of databag item containing SQL credentials</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['osl-imap']['auth_sql']['enable_userdb']</tt></td>
    <td>Boolean</td>
    <td>Whether to enable SQL as an authentication backend for identifying users. Requires <tt>node['dovecot']['conf']['sql']['user_query']</tt> to be specified.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['osl-imap']['auth_sql']['enable_passdb']</tt></td>
    <td>Boolean</td>
    <td>Whether to enable SQL as an authentication backend for verifying passwords. Requires <tt>node['dovecot']['conf']['sql']['password_query']</tt> to be specified.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['osl-imap']['auth_system']['enable_userdb']</tt></td>
    <td>Boolean</td>
    <td>Whether to use the system's passwd file as an authentication backend for identifying users.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['osl-imap']['auth_system']['enable_passdb']</tt></td>
    <td>Boolean</td>
    <td>Whether to enable PAM as an authentication backend for verifying passwords.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['osl-imap']['enable_lmtp']</tt></td>
    <td>Boolean</td>
    <td>Whether to enable Lightweight Mail Transfer Protocol (LMTP) socket (for use with Postfix).</td>
    <td><tt>false</tt></td>
  </tr>
</table>

Usage
-----
To use this cookbook to install and configure dovecot, include `osl-imap::default` and set the
needed attributes from the `osl-imap` and `dovecot` cookbooks. This cookbook includes several
attribute toggles for enabling/disabling different authentication backends for dovecot, but
more specific non-default configurations will require setting relevant attributes in the `dovecot`
cookbook.

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2018, Oregon State University

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
