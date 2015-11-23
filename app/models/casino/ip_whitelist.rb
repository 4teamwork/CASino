class CASino::IPWhitelist
  def initialize(entries)
    @entries = entries
  end

  def include?(ip)
    parsed.any? { |entry| entry.include?(ip) }
  end

  private
  def parsed
    @parsed ||= @entries.map do |entry|
      case entry
      when String
        IPAddr.new(entry)
      when Array
        (IPAddr.new(entry[0])..IPAddr.new(entry[1]))
      end
    end
  end
end
