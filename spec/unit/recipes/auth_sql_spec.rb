require_relative '../../spec_helper'

describe 'osl-imap::auth_sql' do
  include_context 'dovecot_stubs'

  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to include_recipe 'dovecot::default'
      end
      it do
        expect(chef_run).to create_template '(core) dovecot-sql.conf.ext'
      end
      context "SQL databag's database type is not 'mysql' or 'pgsql'" do
        before do
          stub_data_bag_item(nil, nil).and_return(
            type: 'INVALID'
          )
        end
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p).converge(described_recipe)
        end
        it do
          expect { chef_run }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
