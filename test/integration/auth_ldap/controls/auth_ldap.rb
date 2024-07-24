control 'auth_sql' do
  describe command 'doveconf -S userdb passdb' do
    its('stdout') { should match %r{^passdb/0/driver=ldap$} }
    its('stdout') { should match %r{^passdb/0/args=/etc/dovecot/dovecot-ldap.conf.ext$} }
    its('stdout') { should match %r{^userdb/0/driver=ldap$} }
    its('stdout') { should match %r{^userdb/0/args=/etc/dovecot/dovecot-ldap.conf.ext$} }
    its('exit_status') { should eq 0 }
  end

  describe file '/etc/dovecot/dovecot-ldap.conf.ext' do
    its('mode') { should cmp '0640' }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'dovecot' }
    its('content') { should match(%r{^uris = ldaps://ldap\.osuosl\.org$}) }
    its('content') { should match(/^base = ou=People,dc=osuosl,dc=org$/) }
    its('content') { should match(/^auth_bind = yes$/) }
  end
end
