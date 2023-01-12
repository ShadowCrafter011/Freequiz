class BugReportController < ApplicationController
  before_action :require_admin!, except: :create
  before_action do
    setup_locale "bug_report"
  end

  def create
    report = current_user.present? ? current_user.bug_reports.new(bug_report_params) : BugReport.new(bug_report_params)
    if report.save!
      gn s: tp("bug_report_created")
    else
      gn a: tp("failed_to_create")
    end
    redirect_to bug_report_params[:url]
  end

  def list
  end

  def show
  end

  def edit
  end

  def update
  end

  def status
  end

  private
  def bug_report_params
    params.require(:bug_report).permit(:title, :body, :url, :platform)
  end
end
