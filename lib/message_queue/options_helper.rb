module OptionsHelper
  # Internal: Deep clone a Hash. Compute the values in the Hash if responding to :call
  #
  # options - The Hash options to clone
  #
  # Returns the cloned Hash with values computed if responding to :call
  def deep_clone(options = {})
    options.each do |k, v|
      options[k] = v.call if v.respond_to?(:call)
    end
    Marshal.load(Marshal.dump(options)) # deep cloning options
  end
end
