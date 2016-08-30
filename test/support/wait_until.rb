require 'watir-webdriver/wait'

module WaitUntil
  def wait_until(&block)
    raise ArgumentError unless block_given?
    Watir::Wait.until {
      block.call.wait_until_present
    }
    block.call
  end
end
