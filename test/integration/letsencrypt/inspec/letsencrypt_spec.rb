describe service 'dovecot' do
  it { should be_enabled }
  it { should be_running }
end

%w(993 995).each do |p|
  describe port p do
    it { should be_listening }
  end
end

%w(110 143).each do |num|
  describe port num do
    it { should_not be_listening }
  end
end

describe file '/etc/dovecot/conf.d/10-auth.conf' do
  its('content') { should match(/disable_plaintext_auth = yes/) }
  its('content') { should match(/auth_mechanisms = plain login/) }
end

describe file '/etc/dovecot/conf.d/10-master.conf' do
  its('content') do
    should match %r{service auth {
  unix_listener /var/spool/postfix/private/auth {
    group = postfix
    mode = 0660
    user = postfix
  }
}}
  end
end

describe file '/var/spool/postfix/private/auth' do
  it { should be_socket }
  its('mode') { should cmp 0660 }
  its('owner') { should eq 'postfix' }
  its('group') { should eq 'postfix' }
end

describe file '/etc/dovecot/conf.d/10-ssl.conf' do
  its('content') { should match(/ssl = required/) }
  its('content') { should match %r{ssl_cert = </etc/pki/tls/imap.osuosl.org.crt} }
  its('content') { should match %r{ssl_key = </etc/pki/tls/imap.osuosl.org.key} }
end

%w(
  /etc/pki/tls/imap.osuosl.org.crt
  /etc/pki/tls/imap.osuosl.org-chain.crt
  /etc/pki/tls/imap.osuosl.org.key
).each do |f|
  describe file f do
    it { should exist }
  end
end
describe file '/etc/dovecot/dovecot.conf' do
  its('content') { should match(/^protocols = imap pop3$/) }
end

describe file '/etc/dovecot/conf.d/10-auth.conf' do
  # These pertain to system auth, which is enabled by default for this test suite
  its('content') { should match /^auth_username_format = %n$/ }
  its('content') { should match /^!include auth-system.conf.ext$/ }

  # Other auths should be disabled by default
  %w(checkpassword dict ldap passwdfile sql static vpopmail).each do |type|
    its('content') { should match "^#!include auth-#{type}.conf.ext$" }
  end
end

describe file '/etc/dovecot/conf.d/auth-system.conf.ext' do
  its('content') do
    should match(/passdb {
  driver = pam
  args = dovecot
}/)
  end
  its('content') do
    should match(/^userdb {.*driver = passwd.*}$/m)
  end
end

describe command 'doveconf -S userdb passdb' do
  its('stdout') { should match %r{^passdb/0/driver=pam$} }
  its('stdout') { should match %r{^passdb/0/args=dovecot$} }
  its('stdout') { should match %r{^userdb/0/driver=passwd$} }
  its('exit_status') { should eq 0 }
end

# Log in and fetch mail via IMAPS port
describe command %(expect <<< '
spawn openssl s_client -connect localhost:993
expect {
  -re "OK .* Dovecot ready." {
    send -- "1 login foo bar\r"
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
end
