class RootController < ApplicationController
  # GET /dashboard
  def dashboard
    @start_date = Crawl.oldest.started_at.to_date
    @end_date = Crawl.latest.started_at.to_date
    @current_date = begin
      Date.parse(dashboard_params[:date])
    rescue
      @end_date
    end
  end

  # GET /inquiry
  def inquiry
    @inquiry = Inquiry.new
  end

  # POST /inquiry
  def send_inquiry
    @inquiry = Inquiry.new(inquiry_params)

    if @inquiry.valid?
      begin
        InquiryMailer.with(inquiry: @inquiry).inquiry.deliver_now
        flash[:success] = 'Complate to send a message. thank you for your message!'
      rescue StandardError => e
        Rails.logger.error('InquiryMailer') { e.message }
        flash[:warning] = 'Sorry, an error occured in server. please wait for a while.'
      end
      redirect_to action: 'inquiry'
    else
      render action: 'inquiry'
    end
  end

  private

  def dashboard_params
    params.permit(:date)
  end

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :message)
  end
end
