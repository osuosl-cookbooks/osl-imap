
control 'no_ssl' do
  describe package 'dovecot' do
    it { should be_installed }
  end

  describe service 'dovecot' do
    it { should be_enabled }
    it { should be_running }
  end

  %w(993 995).each do |p|
    describe port p do
      it { should_not be_listening }
    end
  end

  %w(110 143).each do |num|
    describe port num do
      it { should be_listening }
    end
  end
end
