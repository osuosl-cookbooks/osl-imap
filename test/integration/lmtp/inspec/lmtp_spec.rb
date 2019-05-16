describe file '/etc/dovecot/dovecot.conf' do
  its('content') { should match(/^protocols = imap lmtp pop3$/) }
end

describe file '/etc/dovecot/conf.d/10-master.conf' do
  its('content') do
    should match %r{service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    group = postfix
    mode = 0600
    user = postfix
  }
}}
  end
end

describe file '/var/spool/postfix/private/dovecot-lmtp' do
  it { should be_socket }
  its('owner') { should eq 'postfix' }
  its('group') { should eq 'postfix' }
  its('mode') { should cmp 0600 }
end

describe file '/etc/postfix/main.cf' do
  its('content') { should match %r{^local_transport = lmtp:unix:private/dovecot-lmtp$} }
  its('content') { should match %r{^virtual_transport = lmtp:unix:private/dovecot-lmtp$} }
end

describe command 'postconf local_transport virtual_transport' do
  its('stdout') { should match %r{^local_transport = lmtp:unix:private/dovecot-lmtp$} }
  its('stdout') { should match %r{^virtual_transport = lmtp:unix:private/dovecot-lmtp$} }
end

describe file '/var/log/maillog' do
  its('content') { should match(/dovecot: lmtp\(foo\): .* saved mail to INBOX$/) }
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
