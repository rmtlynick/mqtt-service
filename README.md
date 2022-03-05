# Ruby Service Framework

The RSF makes it easy to implement a new, MQTT-integrated service in Ruby. It handles:

- loading a YAML config
- connecting to a broker
- subscribing to configured topics
- logging to a topic
- adding supplementary fields to each published message:
    + client_id
    + ip_address
- Docker container with common dependencies installed

## Evolution of Caladan

The consistency of logging topics, supplementary fields, and config format is important, because those features enable other features:

- automated mapping of topic dependencies between services
- integration into logging and monitoring dashboards in kibana
