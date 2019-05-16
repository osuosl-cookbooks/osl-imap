describe file '/etc/dovecot/conf.d/10-auth.conf' do
  its('content') { should match(/^!include auth-sql.conf.ext$/) }
end

describe file '/etc/dovecot/conf.d/auth-sql.conf.ext' do
  its('content') do
    should match %r{passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}}
  end
end

describe file '/etc/dovecot/dovecot-sql.conf.ext' do
  its('content') { should match(/driver = mysql/) }
  its('content') { should match(/connect = host=127.0.0.1 dbname=dovecot user=dovecot_user password=dovecot_pass/) }
  its('content') { should match(/default_pass_scheme = SHA512-CRYPT/) }
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
end
