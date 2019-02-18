name             'osl-imap-test'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
issues_url       'https://github.com/osuosl-cookbooks/osl-imap-test/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-imap-test'
description      'Installs/Configures osl-imap-test'
long_description 'Installs/Configures osl-imap-test'
version          '0.1.0'

depends          'osl-mysql'
depends          'osl-postfix'

supports         'centos', '~> 7.0'
