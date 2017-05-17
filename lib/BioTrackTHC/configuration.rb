module BioTrackTHC
  class Configuration
    attr_accessor :username, :password, :license, :base_uri, :training, :results

    def incomplete?
      [:username, :password, :license, :base_uri].any? { |e| self.send(e).nil? }
    end

  end
end
