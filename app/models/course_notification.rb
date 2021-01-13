# frozen_string_literal: true

class CourseNotification < ApplicationRecord
  attr_accessor :topic, :message, :user, :course
  belongs_to :course
  belongs_to :user
end
