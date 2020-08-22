require 'digest/sha2'

module DigestGenerator
  module_function

  def digest(str)
    Digest::SHA512.hexdigest(str)
  end

  def validate(raw_str, digested_str)
    Digest::SHA512.hexdigest(raw_str) == digested_str
  end
end
