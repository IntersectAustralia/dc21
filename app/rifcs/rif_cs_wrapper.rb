class RifCsWrapper
  attr_accessor :collection_object

  def initialize(collection_object)
    self.collection_object = collection_object
  end

  # for methods that are not defined in the wrapper, delegate to the object being wrapped
  def method_missing(method, *args, &block)
    if collection_object.respond_to?(method)
      collection_object.send(method, *args, &block)
    else
      raise NoMethodError
    end
  end


end