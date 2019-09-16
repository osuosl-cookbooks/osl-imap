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
      %w(
        certificate::wildcard
        dovecot::default
        firewall::imaps_pop3s
      ).each do |recipe|
        it do
          expect(chef_run).to include_recipe recipe
        end
      end
      %w(
        osl-imap::auth_sql
        osl-imap::auth_system
        osl-imap::lmtp
      ).each do |recipe|
        it do
          expect(chef_run).to_not include_recipe recipe
        end
      end
      it do
        expect(chef_run).to_not create_template '(core) dovecot-sql.conf.ext'
      end
      context 'LetsEncrypt enabled' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.force_default['osl-imap']['letsencrypt'] = true
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to_not include_recipe 'certificate::wildcard'
        end
      end
      context 'LMTP enabled' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.force_default['osl-imap']['enable_lmtp'] = true
          end.converge(described_recipe)
          %w(
            certificate::wildcard
            certificate::manage_by_attributes
          ).each do |recipe|
            it do
              expect(chef_run).to_not include_recipe recipe
            end
          end
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
          it do
            expect(chef_run).to include_recipe 'osl-imap::auth_sql'
          end
          it do
            expect(chef_run).to create_template '(core) dovecot-sql.conf.ext'
          end
        end
      end
      %w(userdb passdb).each do |db|
        context "system #{db} enabled" do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.normal['osl-imap']['auth_system']["enable_#{db}"] = true
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to include_recipe 'osl-imap::auth_system'
          end
        end
      end
    end
  end
end
