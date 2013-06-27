class Import < ActiveRecord::Base
  attr_accessible :csv

  has_attached_file :csv,
    path: ":rails_root/doc/url/import_url/:basename.:extension",
    url: "doc/url/import_url/:basename.:extension"

  validates_attachment_presence :csv, presence: true, message: I18n.t('error_message_url_import.not_input')
  validates_attachment_content_type :csv, content_type: ['text/csv','text/comma-separated-values','text/csv','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain'], message: I18n.t('error_message_url_import.not_format_csv')
  validates_attachment_size :csv, less_than: 300.megabytes, message: I18n.t('error_message_url_import.volumn_over')

  def change_file_name(user_id)
    extension = File.extname(csv_file_name).downcase
    self.csv.instance_write(:file_name, "#{user_id}_import_url_#{Time.now.to_i}#{extension}")
  end
end
