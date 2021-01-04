# frozen_string_literal: true

require 'spec_helper'

describe UncomputedUnlock, type: :model do
  describe '#create_all_for_course' do
    before :each do
      @course = FactoryBot.create(:course)
      @user = FactoryBot.create(:user)

      # make the user a course participant
      FactoryBot.create(:awarded_point, course: @course, user: @user)
      expect(User.course_students(@course)).to include(@user)

      # Create irrelevant course and user
      FactoryBot.create(:course)
      FactoryBot.create(:user)
    end

    it 'creates entries for all students of a course' do
      UncomputedUnlock.create_all_for_course(@course)
      expect(UncomputedUnlock.count).to be 1
      expect(UncomputedUnlock.first.course_id).to be @course.id
      expect(UncomputedUnlock.first.user_id).to be @user.id
    end

    it 'tries to not create duplicate entries' do
      UncomputedUnlock.create_all_for_course(@course)
      UncomputedUnlock.create_all_for_course(@course)
      expect(UncomputedUnlock.count).to be 1
    end
  end
end
