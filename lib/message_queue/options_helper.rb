module OptionsHelper
  # Internal: Deep clone a Hash. Compute the values in the Hash if responding to :call
  #
  # options - The Hash options to clone
  #
  # Returns the cloned Hash with values computed if responding to :call
  def deep_clone(options = {})
    compute_values(options)
    Marshal.load(Marshal.dump(options)) # deep cloning options
  end

  # Internal: Recursively compute the value of a Hash if it responds to :call
  #
  # options - The Hash options to compute value for
  #
  # Returns the Hash with values computed if responding to :call
  def compute_values(options = {})
    options.each do |k, v|
      if v.is_a?(Hash)
        compute_values(v)
      else
        options[k] = v.call if v.respond_to?(:call)
      end
    end
  end
end
