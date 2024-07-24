include_recipe 'osl-imap-test::default'

osl_imap_dovecot 'ldap' do
  auth_type :ldap
  wildcard_cert true
  auth_username_format '%Lu'
  ldap_uris 'ldaps://ldap.osuosl.org'
  ldap_base 'ou=People,dc=osuosl,dc=org'
end
