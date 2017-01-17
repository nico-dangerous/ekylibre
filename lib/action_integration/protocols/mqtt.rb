module ActionIntegration
  # Handles the MQTT communication protocol
  module MQTT
    def connect(*args, **kwargs)
      @mqtt_client = MQTT::Client.connect *args, **kwargs
    end

    def publish(topic, payload, retain = false)
      @mqtt_client.publish(topic, payload, retain)
    end

    def subscribe(*topics)
      @mqtt_client.subscribe(*topics)
    end

    def get(topic=nil, &block)
      @mqtt_client.get(topic, &block)
    end
  end
end
