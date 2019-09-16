class RootController < ApplicationController
  before_action :set_current_date, :dashboard
  before_action :set_start_date, :dashboard

  # GET /dashboard
  def dashboard
    crawl = Crawl.where(started_at: @current_date.all_day).first
    @evaluations = crawl.evaluations.order(score: :desc).limit(5)
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

  def set_current_date
    @current_date = if dashboard_params[:date].present?
              Date.parse(dashboard_params[:date])
            else
              xs = Crawl.order(started_at: :desc).limit(2).to_a
              xs.shift unless xs.first.finished?
              xs.first.started_at.to_date
            end
  end

  def set_start_date
    @start_date = Crawl.order(:started_at).first.started_at.to_date
  end
end
