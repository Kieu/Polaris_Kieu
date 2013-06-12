class ImportUrl
  include Resque::Plugins::Status
  @queue = :import_url
  
  def perform
    require "csv"
    type = options['type']
    job_id = BackgroundJob.find(options['bgj_id']).job_id
    CSV.foreach(options['file'], headers: true) do |row|
      Client.create(
        client_name: row[0],
        roman_name: row[1],
        tel: row[2],
        contract_flg: row[3],
        contract_type: row[4],
        person_charge: row[5],
        person_sale: row[6]
      )
    end
  end
end
