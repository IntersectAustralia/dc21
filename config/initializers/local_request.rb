module ActionDispatch
  class Request < Rack::Request
    def local?
      false
    end
  end
end

