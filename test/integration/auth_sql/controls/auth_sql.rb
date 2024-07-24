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

  describe file '/var/log/maillog' do
    its('content') { should match %r{postfix/local.* to=<foo@foo.org>.* status=sent \(delivered to maildir\)$} }
  end

  # Log in and fetch mail via IMAPS port
  describe command %(expect <<< '
spawn openssl s_client -connect localhost:993
expect {
  -re "OK .* Dovecot ready." {
    send -- "1 login foo@foo.org bar\r"
    exp_continue
  } -re "1 OK .* Logged in" {
    send -- "2 select inbox\r"
    exp_continue
  } -re "2 OK .* Select completed" {
    send -- "3 FETCH 1:* BODY\\[TEXT\\]\r"
    exp_continue
  } "This test email should be fetchable via IMAP" {
    exit 0
  } default {
    exit 1
  }
}') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/This test email should be fetchable via IMAP/) }
    its('stderr') { should cmp '' }
  end
end
