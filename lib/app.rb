#!/usr/bin/env ruby

require 'mqtt_service'

# sample MqttService implementation
class HelloMqttService < MqttService
  def initialize
    super
  end
  
  def mqtt_receive(topic, msg, msg_hash)
    log_msg = "Received a message on #{topic}: #{msg}"
    logger.debug(log_msg)
    logger.data(log_msg)
    logger.info(log_msg)
    logger.warn(log_msg)
    logger.error(log_msg)
    logger.error_bold(log_msg)
    publish(@config['mqtt']['topics']['pub'], @config['mqtt']['client_id'])
  end
end

HelloMqttService.new if $PROGRAM_NAME == __FILE__
