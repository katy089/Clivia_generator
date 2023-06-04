require "httparty"
require "json"

class CliviaAPI
  include HTTParty
  base_uri "https://opentdb.com/api.php?amount=10"

  def self.index
    response = HTTParty.get(base_uri)
    JSON.parse(response.body, symbolize_names: true)
  end
end
