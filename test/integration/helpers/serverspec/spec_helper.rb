require 'serverspec'

set :backend, :exec

shared_examples_for 'dovecot' do
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
    its(:content) { should match(/disable_plaintext_auth = yes/) }
    its(:content) { should match(/auth_mechanisms = plain login/) }
  end

  describe file '/etc/dovecot/conf.d/10-master.conf' do
    its(:content) do
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
    it { should be_mode 660 }
    it { should be_owned_by 'postfix' }
    it { should be_grouped_into 'postfix' }
  end

  describe file '/etc/dovecot/conf.d/10-ssl.conf' do
    its(:content) { should match(/ssl = required/) }
    its(:content) { should match %r{ssl_cert = </etc/pki/tls/certs/wildcard.pem} }
    its(:content) { should match %r{ssl_key = </etc/pki/tls/private/wildcard.key} }
  end

  %w(
    /etc/pki/tls/certs/wildcard.pem
    /etc/pki/tls/certs/wildcard-bundle.crt
    /etc/pki/tls/private/wildcard.key
  ).each do |f|
    describe file f do
      it { should exist }
    end
  end
end
