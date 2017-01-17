# Sending SMS.
class OctopushService
  Struct.new('SMSMode', :code, :name, :mandatory_message)

  TYPES = [
    Struct::SMSMode.new(:XXX, :low_cost, 'no PUB=STOP').freeze,
    Struct::SMSMode.new(:FR, :premium, 'STOP au XXXXX').freeze,
    Struct::SMSMode.new(:WWW, :world, '').freeze
  ].freeze

  def initialize
    @client = Octopush::Client.new
  end

  def send_sms(to = nil, message = nil, type: nil, from: 'Ekylibre', &block)
    raise "Can't handle both block and params." if block_given? && (to || message)
    sms = Octopush::SMS.new
    sms.instance_eval(&block) if block_given?
    complete_sms(sms, message, to, type, from)
    add_stop_mention unless
    @client.send_sms(sms)
  end

  private

  def complete_sms(sms, message, to, type, from)
    sms.sms_text         = message_with_stop(sms.sms_text || message, sms.sms_type || type)
    sms.sms_recipients ||= to.respond_to?(:join) ? to.join(',') : to
    sms.sms_type       ||= type || 'FR'
    sms.sms_sender     ||= from
  end

  def message_with_stop(message, type_code)
    type = get_type(type_code)
    return message if message.index(type.mandatory_message)
    "#{message}\n#{type.mandatory_message}"
  end

  def get_type(code)
    TYPES.find { |type| type.code == code.to_sym }
  end
end
