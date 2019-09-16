name             'osl-imap'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
issues_url       'https://github.com/osuosl-cookbooks/osl-imap/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-imap'
description      'Installs/Configures osl-imap'
long_description 'Installs/Configures osl-imap'
version          '1.1.0'

supports         'centos', '~> 7.0'

depends          'certificate'
depends          'dovecot', '~> 3.3.0'
depends          'firewall'
