control 'letsencrypt' do
  describe command 'doveconf -S' do
    its('exit_status') { should eq 0 }
    its('stdout') { should match %r{^ssl_cert=</etc/pki/tls/imap\.osuosl\.org\.crt$} }
    its('stdout') { should match %r{^ssl_key=</etc/pki/tls/imap\.osuosl\.org\.key$} }
  end
end
