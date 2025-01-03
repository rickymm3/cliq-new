class MigrateReplyLegacyContentToActionText < ActiveRecord::Migration[7.0]
  def up
    Reply.find_each do |reply|
      next if reply.legacy_content.blank?
      reply.update!(content: reply.legacy_content)
    end
  end

  def down
    # If you want to revert
    Reply.find_each do |reply|
      if reply.content.body.present?
        reply.update_column(:legacy_content, reply.content.to_s)
      end
    end
  end
end
