require_relative '../../spec_helper'

describe 'osl-imap::default' do
  include_context 'dovecot_stubs'

  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { expect(chef_run).to accept_osl_firewall_imaps_pop3s('osl-imap') }

      it do
        expect(chef_run).to create_certificate_manage('wildcard').with(
          cert_file: 'wildcard.pem',
          key_file: 'wildcard.key',
          chain_file: 'wildcard-bundle.crt'
        )
        it { expect(chef_run.certificate_manage('wildcard')).to notify('service[apache2]').to(:reload) }
      end
      it { expect(chef_run).to include_recipe('dovecot::default') }

      %w(
        osl-imap::auth_sql
        osl-imap::auth_system
        osl-imap::lmtp
      ).each do |r|
        it { expect(chef_run).to_not include_recipe(r) }
      end

      it { expect(chef_run).to_not create_template('(core) dovecot-sql.conf.ext') }

      context 'LetsEncrypt enabled' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.force_default['osl-imap']['letsencrypt'] = true
          end.converge(described_recipe)
        end

        it { expect(chef_run).to_not create_certificate_manage('wildcard') }
      end

      context 'LMTP enabled' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.force_default['osl-imap']['enable_lmtp'] = true
          end.converge(described_recipe)

          it { expect(chef_run).to_not create_certificate_manage('wildcard') }
        end
      end

      %w(userdb passdb).each do |db|
        context "SQL #{db} enabled" do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.normal['osl-imap']['auth_sql']["enable_#{db}"] = true
              node.normal['dovecot']['conf']['sql']['user_query'] = "SELECT home, uid, gid FROM users WHERE userid = '%u'"
              node.normal['dovecot']['conf']['sql']['password_query'] = 'SELECT username, domain, password' \
                "FROM users WHERE username = '%n' AND domain = '%d'"
            end.converge(described_recipe)
          end

          it { expect(chef_run).to include_recipe('osl-imap::auth_sql') }

          it { expect(chef_run).to create_template('(core) dovecot-sql.conf.ext') }
        end
      end

      %w(userdb passdb).each do |db|
        context "system #{db} enabled" do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.normal['osl-imap']['auth_system']["enable_#{db}"] = true
            end.converge(described_recipe)
          end

          it { expect(chef_run).to include_recipe('osl-imap::auth_system') }
        end
      end
    end
  end
end
