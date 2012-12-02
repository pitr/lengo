class SpeechController < ApplicationController
  def tts
    text = params[:text]

    options = {
      :tl => :en,
      :q  => text
    }.to_query

    body = ::RestClient.get "http://translate.google.com/translate_tts?#{options}", :user_agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17'
    render :text => body, :content_type => 'audio/mpeg'
  end
end
