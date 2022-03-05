# mqtt-service

mqtt-service makes it easy to implement a new, MQTT-integrated service in Ruby. It handles:

- loading a YAML config
- connecting to a broker
- subscribing to configured topics
- logging to a topic
- adding supplementary fields to each published message:
    + client_id
    + ip_address
- Docker container with common dependencies installed
