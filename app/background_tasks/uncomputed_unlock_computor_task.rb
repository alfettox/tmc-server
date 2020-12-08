# frozen_string_literal: true

require 'submission_processor'

class UncomputedUnlockComputorTask
  def initialize
  end

  def run
    UncomputedUnlock.order('id ASC').limit(1).each do |uncomputed_unlock|
      course = uncomputed_unlock.course
      user = uncomputed_unlock.user
      Rails.logger.info "Calculating unlocks for user #{user.id} and course #{course.name}. Queue length: #{UncomputedUnlock.count}."
      Unlock.refresh_unlocks(course, user)
    end
  end

  def wait_delay
    0.1
  end
end
