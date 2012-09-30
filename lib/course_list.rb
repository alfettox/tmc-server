# Builds /courses.json
class CourseList
  def initialize(user, courses, helpers)
    @user = user
    @courses = courses
    @helpers = helpers
  end

  def course_list_data
    @courses.map {|c| course_data(c) }
  end

private
  def course_data(course)
    exercises = course.exercises.includes(:available_points).natsort_by(&:name)

    {
      :id => course.id,
      :name => course.name,
      :reviews_url => @helpers.course_reviews_url(course, :format => :json),
      :comet_url => CometServer.get.client_url,
      :exercises => exercises.map {|ex| exercise_data(ex) }.reject(&:nil?)
    }
  end

  def exercise_data(exercise)
    return nil if !exercise.visible_to?(@user)

    #TODO: optimize and/or cache parts of it
    data = {
      :id => exercise.id,
      :name => exercise.name,
      :deadline => exercise.deadline,
      :checksum => exercise.checksum,
      :return_url => exercise_return_url(exercise),
      :zip_url => @helpers.exercise_zip_url(exercise),
      :returnable => exercise.returnable?,
      :requires_review => exercise.requires_review?,
      :attempted => exercise.attempted_by?(@user),
      :completed => exercise.completed_by?(@user),
      :reviewed => exercise.reviewed_for?(@user),
      :all_review_points_given => exercise.all_review_points_given_for?(@user),
      :memory_limit => exercise.memory_limit
    }

    data[:solution_zip_url] = @helpers.exercise_solution_zip_url(exercise) if @user.administrator?

    data
  end

  def exercise_return_url(e)
    "#{@helpers.exercise_submissions_url(e, :format => 'json')}"
  end
end