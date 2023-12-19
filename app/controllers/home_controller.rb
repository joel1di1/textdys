# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # This will render the form
  end

  def transform_text
    input_text = params[:text]
    @transformed_text = WordPreparer.new.prepare(input_text)

    render :index
  end
end
