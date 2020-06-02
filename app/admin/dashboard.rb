ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1

  content do
    panel 'Current crawling' do
      if (jobs = controller.instance_variable_get(:@processing)).present?
        jobs.each do |job|
          attributes_table_for job do
            row :started_at
            row :processing do
              ul do
                job[:processing].each do |id, name|
                  li do
                    status_tag id, class: 'no'
                    span name
                  end
                end
              end
              nil
            end
            row :finished
            row :total
          end
        end
      else
        div class: 'no_jobs' do
          span 'No crawls in progress'
        end
      end
    end

    panel 'Scheduled crawls' do
      if (jobs = controller.instance_variable_get(:@scheduled)).present?
        table_for jobs do
          column :start_at
          column 'endpoint order', :order
        end
      else
        div class: 'no_jobs' do
          span 'No scheduled crawls'
        end
      end
    end
  end

  controller do
    def index
      total = Endpoint.active.count

      @processing = if (xs = Crawl.processing).present?
                      xs.processing.map do |x|
                        {
                          started_at: x.started_at.to_formatted_s,
                          processing: Endpoint.where(id: x.processing.map(&:last)).order(:id).pluck(:id, :name),
                          finished: x.evaluations.count - x.processing.size,
                          total: total
                        }
                      end
                    else
                      []
                    end

      @scheduled = (Time.current < Crawl.start_time(Date.current) ? (0..7) : (1..8)).map do |n|
        date = Date.current.since(n.days)
        {
          start_at: Crawl.start_time(date).to_formatted_s,
          order: Crawl.queue_order(date)
        }
      end
    end
  end
end
