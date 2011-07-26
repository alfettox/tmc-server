class SubmissionsController < ApplicationController
  before_filter :get_course_and_exercise

  def index
    @submissions = Submission.where(:exercise_id => @exercise.id)

    respond_to do |format|
      format.html
    end
  end

  def show
    @submission = Submission.find(params[:id])

    respond_to do |format|
      format.html
      format.zip { send_data(@submission.return_file) }
      format.json do
        output = {
          :status => @submission.status
        }
        output = output.merge(
          case @submission.status
          when :error then { :error => @submission.pretest_error }
          when :fail then { :failures => @submission.test_failure_messages }
          when :ok then {}
          end
        )
        render :json => output
      end
    end
  end

  def create
    student_id = params[:submission][:student_id]
    user = User.find_by_login(student_id)
    user ||= User.create!(:login => student_id, :password => nil)
    
    @submission = Submission.new(
      :user => user,
      :exercise => @exercise,
      :return_file_tmp_path => params[:submission][:tmp_file].tempfile.path
    )

    ok = @submission.save
    
    respond_to do |format|
      format.html do
        if ok
          redirect_to(course_exercise_submission_path(@course, @exercise, @submission),
                      :notice => 'Submission processed.')
        else
          redirect_to(course_exercise_path(@course, @exercise),
                      :alert => 'Failed to process submission.') 
        end
      end
      format.json do
        if ok
          redirect_to(course_exercise_submission_path(@course, @exercise, @submission, :format => 'json'))
        else
          render :json => {:error => 'Failed to save submission. Sorry :('}
        end
      end
    end
  end

private
  def get_course_and_exercise
    @course = Course.find(params[:course_id])
    @exercise = @course.exercises.find(params[:exercise_id])
  end
end
