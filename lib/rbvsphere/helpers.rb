module VSphere::Helpers
  def self.validate_parameters_presence expect, got
    ret = []
    expect.each do |k|
      ret << k unless got.has_key? k
    end
    raise "Absent Parameters (#{ret.join(", ")})" unless ret.empty?
  end
end
