class BugReportController < ApplicationController
  before_action :require_admin!, except: :create
  before_action do
    setup_locale "bug_report"
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

  def show
    @bug = BugReport.find(params[:bug_id])
  end

  def status
    if BugReport.find(params[:bug_id]).update(status_params)
      gn s: "Status updated #{status_params}"
    else
      gn a: "Status could not be updated"
    end
    redirect_to bug_path(params[:bug_id])
  end

  private
  def bug_report_params
    params.require(:bug_report).permit(:title, :body, :url, :platform, :user_agent, :original_url)
  end

  def status_params
    params.require(:bug_report).permit(:status)
  end
end
