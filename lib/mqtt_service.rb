#!/usr/bin/env ruby
# frozen_string_literal: true

require 'mqtt'
require 'yaml'
require 'json'
require 'recursive_open_struct'
require_relative 'logging'

# framework for building ruby-based MQTT services
class MqttService
  CONFIG_FILENAME = 'config.yml'

  attr_reader :logger

  def self.build_config_filename(app_file_path)
    File.join(app_file_path, '..', 'etc', CONFIG_FILENAME)
  end

  def initialize(config_path: nil)
    config_path ||= self.class.build_config_filename(__dir__)

    puts "Loading config from '#{config_path}'..."
    @config = RecursiveOpenStruct.new(YAML.load_file(config_path))

    puts 'Setting up logger...'
    @logger = MqttServiceLogger.new(@config.log)

    @logger.info('Creating MQTT client...')
    @mqtt_client = MQTT::Client.connect(
      host: @config.mqtt.host,
      port: @config.mqtt.port,
      ssl: @config.mqtt.ssl
    )

    subscribe_to_topics
    subscribe_to_ping
  end

  def run
    @run = true
    do_loop
  end

  def stop
    @run = false
  end

  private

  def subscribe_to_topics
    topics = @config.mqtt.topics.sub
    unless topics&.any?
      @logger.info('No topics to which to subscribe.')
      return
    end
    topics.each do |topic|
      @logger.debug("Subscribing to #{topic}...")
      subscribe(topic)
    end
  end

  def subscribe_to_ping
    @logger.debug("Subscribing to #{ping_topic}...")
    subscribe(ping_topic)
  end

  def subscribe(topic)
    @logger.info('SUB ' + topic)
    @mqtt_client.subscribe(topic)
  end

  def publish(topic, payload, retain=false)
    payload = {_msg: payload} unless payload.is_a?(Hash)

    add_client_id(payload)
    payload = payload.to_json
    @logger.info('PUB ' + topic + ' | ' + payload.to_s)
    @mqtt_client.publish(topic, payload, retain: retain)
  end

  def ping_topic
    @ping_topic ||= @config.mqtt.topics.ping + '/' + @config.mqtt.client_id
  end

  def pong_topic
    @pong_topic ||= @config.mqtt.topics.pong + '/' + @config.mqtt.client_id
  end

  def decode_message(msg)
    begin
      msg_hash = JSON.parse(msg)
      msg_hash = nil unless msg_hash.class == Hash
    rescue JSON::ParserError
      msg_hash = nil
    end
    msg_hash
  end

  def mqtt_receive_shim(topic, msg, msg_hash)
    @logger.info "#{topic} #{msg}"
    if topic == ping_topic
      @logger.debug('Handling ping...')
      publish(pong_topic, state: true)
    else
      mqtt_receive(topic, msg, msg_hash)
    end
  end

  def do_loop
    while @run
      begin
        @mqtt_client.get(nil, @config.mqtt.client) do |topic, msg|
          @logger.debug 'RCV ' + topic + ' | ' + msg.to_s
          msg_hash = decode_message(msg)
          mqtt_receive_shim(topic, msg, msg_hash)
        end
      rescue SystemExit, Interrupt
        raise
      rescue StandardError => e
        @logger.error_bold e.message
        @logger.error '    ' + e.backtrace.join($/ + '    ')
      end
    end
  rescue Interrupt => e
    @logger.info '[INT] Exiting...'
    begin
      @mqtt_client.disconnect
    rescue Interrupt
      @logger.info '[INT] Aborting...'
    end
  end

  def add_client_id(payload)
    payload[:clientid] = @config.mqtt.client_id
  end
end

MqttService.new.run if $PROGRAM_NAME == __FILE__
