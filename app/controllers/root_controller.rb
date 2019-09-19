class RootController < ApplicationController
  # GET /dashboard
  def dashboard
    @date = {
      start: Crawl.oldest.started_at.to_date,
      end: (latest = Crawl.latest.started_at.to_date),
      current: begin
        Date.parse(dashboard_params[:date])
      rescue
        latest
      end
    }

    @metrics = metrics
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

  def metrics
    recent = Crawl.finished.order(started_at: :desc).limit(8).to_a

    return Hash.new { {} } if recent.blank?

    latest = recent.shift
    yesterday = recent.shift
    last_week = recent.find { |x| x.started_at.to_date <= 7.days.ago(Date.current) }

    {
      data_collection: {
        current: Crawl.data_collection,
        diff: Crawl.days_without_data
      },
      no_of_endpoints: {
        current: (v = latest.number_of_endpoints),
        diff: if last_week.present?
                v - last_week.number_of_endpoints
              end
      },
      active_endpoints: {
        current: (v = latest.number_of_active_endpoints),
        diff: if yesterday.present?
                v - yesterday.number_of_active_endpoints
              end
      },
      alive_rate: {
        current: ((v = latest.alive_rate) * 100).round(0),
        diff: if last_week.present?
                ((v - last_week.alive_rate) * 100).round(0)
              end
      },
      data_entries: {
        current: (v = latest.data_entries),
        diff: if yesterday.present?
                v - yesterday.data_entries
              end
      }
    }
  end
end
