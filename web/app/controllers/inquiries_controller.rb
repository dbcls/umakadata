class InquiriesController < ApplicationController

  def form
    @inquiry = Inquiry.new
  end

  def send_inquiry
    @inquiry = Inquiry.new(inquiry_params)
    if @inquiry.valid?
      begin
        ContactUs.send_mail(@inquiry).deliver_now
        flash[:success] = 'Complate to send a message. thank you for your maessage!'
      rescue
        flash[:warning] = 'Sorry, an error occured in server. please wait for a while.'
      end
      redirect_to :action => 'form'
    else
      render :action => 'form'
    end
  end
  
  private
    def inquiry_params
      params.require(:inquiry).permit(:name, :email, :message)
    end

end
