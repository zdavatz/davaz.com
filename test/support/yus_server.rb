require 'minitest'
require 'minitest/autorun'
require 'flexmock/minitest'
require 'support/override_config'
module DaVaz
  def self.GetMockYusServer
    @yus_session = FlexMock.new('yus_session')
    @yus_session.should_receive(:valid?).by_default.and_return(true)
    @yus_session.should_receive(:generate_token).by_default.and_return('generate_token')
    @yus_session.should_receive(:name).by_default.and_return(DaVaz.config.test_user)
    @yus_session.should_receive(:allowed?).by_default.and_return(true)
    @mock = FlexMock.new('yus_server')
    @mock.should_receive(:logout).by_default.and_return(true)
    @mock.should_receive(:login).with(DaVaz.config.test_user, DaVaz.config.test_password, DaVaz.config.yus_domain).by_default.and_return(@yus_session)
    @mock
  end
end
