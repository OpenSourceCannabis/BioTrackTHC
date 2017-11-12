module BioTrackTHC
  class Configuration
    attr_accessor :username,
                  :password,
                  :license,
                  :base_uri,
                  :training,
                  :results,
                  :state

    def incomplete?
      [:username, :password, :license, :base_uri, :state].any? { |e| self.send(e).nil? }
    end

  end
end
