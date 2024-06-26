class BugReportController < ApplicationController
  before_action :require_admin!, except: :create
  before_action do
    setup_locale "bug_report"
  end

  before_action only: [:show, :status] do
    @bug = BugReport.find_by(id: params[:bug_id])
    gn a: "This bug report doesn't exist" unless !!@bug
    redirect_to bugs_path(category: "new") unless !!@bug
  end

  def create
    bug_params = bug_report_params.except(:original_url)
    report = current_user.present? ? current_user.bug_reports.new(bug_params) : BugReport.new(bug_params)
    if report.save!
      gn s: tp("bug_report_created")
    else
      gn a: tp("failed_to_create")
    end
    redirect_to bug_report_params[:original_url]
  end

  def list
    @category = params[:category] || "all"
    @category = BugReport::STATUSES.include?(@category) ? @category : "all"
    @bug_reports = @category == "all" ? BugReport.all.order(created_at: :desc) : BugReport.where(status: @category).order(created_at: :desc)
  end

  def show;  end

  def status
    if @bug.update(status_params)
      gn s: "Status updated"
    else
      gn a: "Status could not be updated"
    end
    redirect_to bug_path(@bug.id)
  end

  private
  def bug_report_params
    params.require(:bug_report).permit(:title, :body, :url, :platform, :user_agent, :original_url)
  end

  def status_params
    params.require(:bug_report).permit(:status)
  end
end
