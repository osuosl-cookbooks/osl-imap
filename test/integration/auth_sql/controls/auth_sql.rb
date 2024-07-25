control 'auth_sql' do
  describe package 'dovecot-mysql' do
    it { should be_installed }
  end

  describe command 'doveconf -S userdb passdb' do
    its('stdout') { should match %r{^passdb/0/driver=sql$} }
    its('stdout') { should match %r{^passdb/0/args=/etc/dovecot/dovecot-sql.conf.ext$} }
    its('stdout') { should match %r{^userdb/0/driver=sql$} }
    its('stdout') { should match %r{^userdb/0/args=/etc/dovecot/dovecot-sql.conf.ext$} }
    its('exit_status') { should eq 0 }
  end

  describe file '/etc/dovecot/dovecot-sql.conf.ext' do
    its('mode') { should cmp '0640' }
    its('owner') { should cmp 'root' }
    its('group') { should cmp 'dovecot' }
    its('content') { should match(/^driver = mysql$/) }
    its('content') { should match(/^connect = host=127.0.0.1 dbname=dovecot user=dovecot_user password=dovecot_pass$/) }
    its('content') { should match(/^default_pass_scheme = SHA512-CRYPT$/) }
  end

  # Log in and fetch mail via IMAPS port
  describe command 'grep -r ^Subject: /tmp/Maildir' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Subject: IMAP Test Email for Foo/) }
  end
end
