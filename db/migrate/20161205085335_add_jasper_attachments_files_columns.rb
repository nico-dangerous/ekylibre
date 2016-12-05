class AddJasperAttachmentsFilesColumns < ActiveRecord::Migration
  def up
    add_attachment :document_templates, :jrxml_file_path
    add_attachment :document_templates, :jasper_file_path
  end

  def down
    remove_attachment :document_templates, :jrxml_file_path
    remove_attachment :document_templates, :jasper_file_path
  end
end
